import os
import time
import pandas as pd
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler
from torchvision import models, transforms
from PIL import Image
from sklearn.metrics import confusion_matrix, classification_report
import warnings
warnings.filterwarnings('ignore')

class APTOSDataset(Dataset):
    def __init__(self, csv_file, img_dir, transform=None):
        self.df = pd.read_csv(csv_file)
        self.img_dir = img_dir
        self.transform = transform

    def __len__(self):
        return len(self.df)

    def __getitem__(self, idx):
        row = self.df.iloc[idx]
        img_name = os.path.join(self.img_dir, f"{row['id_code']}.png")
        image = Image.open(img_name).convert('RGB')
        label = row['diagnosis']
        
        if self.transform:
            image = self.transform(image)
            
        return image, label

def get_transforms():
    train_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(15),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406],
                             std=[0.229, 0.224, 0.225])
    ])
    
    val_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406],
                             std=[0.229, 0.224, 0.225])
    ])
    return train_transform, val_transform

def get_sampler(train_df):
    class_counts = train_df['diagnosis'].value_counts().sort_index().values
    class_weights = 1.0 / class_counts
    sample_weights = [class_weights[label] for label in train_df['diagnosis']]
    sampler = WeightedRandomSampler(sample_weights, num_samples=len(sample_weights), replacement=True)
    return sampler

def main():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")
    
    # Define dataset paths
    img_dir = 'datasets/1. Classification - APTOS/train_images'
    train_csv = 'datasets/1. Classification - APTOS/splits/train_split.csv'
    val_csv = 'datasets/1. Classification - APTOS/splits/val_split.csv'
    
    if not os.path.exists(train_csv):
        print(f"Error: {train_csv} not found.")
        return
        
    train_df = pd.read_csv(train_csv)
    
    train_tf, val_tf = get_transforms()
    
    train_dataset = APTOSDataset(train_csv, img_dir, transform=train_tf)
    val_dataset = APTOSDataset(val_csv, img_dir, transform=val_tf)
    
    sampler = get_sampler(train_df)
    train_loader = DataLoader(train_dataset, batch_size=32, sampler=sampler, num_workers=4)
    val_loader = DataLoader(val_dataset, batch_size=32, shuffle=False, num_workers=4)
    
    model = models.resnet18(pretrained=True)
    num_ftrs = model.fc.in_features
    model.fc = nn.Linear(num_ftrs, 5)
    model = model.to(device)
    
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=1e-4)
    
    num_epochs = 3 # Fast training for prototype baseline
    
    print("Starting training...")
    for epoch in range(num_epochs):
        model.train()
        running_loss = 0.0
        correct = 0
        total = 0
        
        start_time = time.time()
        for images, labels in train_loader:
            images, labels = images.to(device), labels.to(device)
            
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item() * images.size(0)
            _, preds = torch.max(outputs, 1)
            correct += torch.sum(preds == labels.data)
            total += labels.size(0)
            
        epoch_loss = running_loss / total
        epoch_acc = correct.double() / total
        print(f"Epoch {epoch+1}/{num_epochs} - Loss: {epoch_loss:.4f}, Acc: {epoch_acc:.4f} - Time: {time.time()-start_time:.1f}s")
        
    print("\nEvaluating on Validation Set...")
    model.eval()
    all_preds = []
    all_labels = []
    
    with torch.no_grad():
        for images, labels in val_loader:
            images = images.to(device)
            outputs = model(images)
            _, preds = torch.max(outputs, 1)
            all_preds.extend(preds.cpu().numpy())
            all_labels.extend(labels.numpy())
            
    cm = confusion_matrix(all_labels, all_preds)
    print("\nConfusion Matrix:")
    print(cm)
    
    print("\nClassification Report (5-class):")
    print(classification_report(all_labels, all_preds))
    
    # Calculate Level 2+ Sensitivity & Specificity
    # Non-referable: 0, 1 (Negative)
    # Referable: 2, 3, 4 (Positive)
    
    binary_labels = [1 if x >= 2 else 0 for x in all_labels]
    binary_preds = [1 if x >= 2 else 0 for x in all_preds]
    
    tn, fp, fn, tp = confusion_matrix(binary_labels, binary_preds).ravel()
    
    sensitivity = tp / (tp + fn) if (tp + fn) > 0 else 0.0
    specificity = tn / (tn + fp) if (tn + fp) > 0 else 0.0
    
    print("\n--- Binary Referable DR (Level 2+) Metrics ---")
    print(f"True Positives (TP): {tp}")
    print(f"True Negatives (TN): {tn}")
    print(f"False Positives (FP): {fp}")
    print(f"False Negatives (FN): {fn}")
    print(f"Sensitivity (Target > 0.90): {sensitivity:.4f}")
    print(f"Specificity (Target > 0.85): {specificity:.4f}")
    
    # Save the model
    os.makedirs('models', exist_ok=True)
    torch.save(model.state_dict(), 'models/aptos_resnet18_baseline.pth')
    print("Model saved to models/aptos_resnet18_baseline.pth")

if __name__ == "__main__":
    main()
