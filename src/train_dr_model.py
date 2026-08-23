import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms, models
from PIL import Image
import pandas as pd
from tqdm import tqdm

class APTOSDataset(Dataset):
    """
    Custom PyTorch Dataset for the APTOS 2019 Blindness Detection dataset.
    """
    def __init__(self, csv_file, root_dir, transform=None):
        self.annotations = pd.read_csv(csv_file)
        self.root_dir = root_dir
        self.transform = transform

    def __len__(self):
        return len(self.annotations)

    def __getitem__(self, index):
        img_id = self.annotations.iloc[index, 0]
        img_path = os.path.join(self.root_dir, f"{img_id}.png")
        image = Image.open(img_path).convert("RGB")
        y_label = torch.tensor(int(self.annotations.iloc[index, 1]))

        if self.transform:
            image = self.transform(image)

        return (image, y_label)

def get_transforms():
    """
    Returns the image transformations for the ResNet-50 architecture.
    Applies Data Augmentation for training robust medical models.
    """
    return transforms.Compose([
        transforms.Resize((512, 512)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomVerticalFlip(),
        transforms.RandomRotation(20),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], 
                           std=[0.229, 0.224, 0.225])
    ])

def build_model(num_classes=5):
    """
    Builds the ResNet-50 Transfer Learning architecture.
    """
    print("Building ResNet-50 architecture...")
    model = models.resnet50(weights=models.ResNet50_Weights.DEFAULT)
    
    # Freeze early layers to prevent catastrophic forgetting
    for param in list(model.parameters())[:-20]:
        param.requires_grad = False
        
    num_ftrs = model.fc.in_features
    model.fc = nn.Linear(num_ftrs, num_classes)
    return model

def train_model(model, train_loader, criterion, optimizer, num_epochs=10, device='cuda'):
    """
    Main training loop for the AI Grading engine.
    """
    model.to(device)
    
    for epoch in range(num_epochs):
        model.train()
        running_loss = 0.0
        correct = 0
        total = 0
        
        progress_bar = tqdm(train_loader, desc=f"Epoch {epoch+1}/{num_epochs}")
        for images, labels in progress_bar:
            images, labels = images.to(device), labels.to(device)
            
            # Forward pass
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            # Backward pass
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            # Metrics
            running_loss += loss.item()
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
            
            progress_bar.set_postfix({'Loss': loss.item(), 'Acc': 100 * correct / total})
            
    return model

def export_to_onnx(model, output_path="models/dr_resnet50.onnx", device='cpu'):
    """
    Exports the trained PyTorch model to ONNX format.
    This bridge allows our edge-deployment software (MATLAB) to run the PyTorch weights.
    """
    print(f"Exporting PyTorch model to ONNX -> {output_path}")
    model.eval()
    model.to(device)
    dummy_input = torch.randn(1, 3, 512, 512).to(device)
    
    # Ensure models directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    torch.onnx.export(
        model, 
        dummy_input, 
        output_path,
        export_params=True,
        opset_version=14,
        do_constant_folding=True,
        input_names=['input'],
        output_names=['output'],
        dynamic_axes={'input': {0: 'batch_size'}, 'output': {0: 'batch_size'}}
    )
    print("Export Complete.")

if __name__ == "__main__":
    # Example execution flow
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Using device: {device}")
    
    # In a real environment, you would map these to your Kaggle dataset paths
    # csv_file = 'datasets/classification/aptos2019/train.csv'
    # root_dir = 'datasets/classification/aptos2019/train_images'
    
    model = build_model(num_classes=5)
    
    # Exporting the architecture to ONNX for MATLAB deployment
    export_to_onnx(model, output_path="../models/dr_resnet50.onnx", device='cpu')
