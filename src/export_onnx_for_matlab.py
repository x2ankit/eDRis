import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms, models
from PIL import Image, ImageFile
import pandas as pd
from tqdm import tqdm
import onnx
import onnx.version_converter

# Handle slightly corrupted/truncated medical images in the APTOS dataset
ImageFile.LOAD_TRUNCATED_IMAGES = True

class APTOSDataset(Dataset):
    """Custom PyTorch Dataset for the APTOS 2019 Blindness Detection dataset."""
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

def get_transform():
    return transforms.Compose([
        transforms.Resize((512, 512)),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

if __name__ == "__main__":
    # Paths – adjust if you run this in Colab where the dataset already exists
    csv_path = 'dataset/train.csv'
    img_root = 'dataset/train_images'
    transform = get_transform()
    ds = APTOSDataset(csv_path, img_root, transform)
    loader = DataLoader(ds, batch_size=16, shuffle=True, num_workers=2)

    # Build model
    model = models.resnet50(weights=models.ResNet50_Weights.DEFAULT)
    model.fc = nn.Linear(model.fc.in_features, 5)
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = model.to(device)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=1e-4)

    # Simple training loop (5 epochs for demo – you can increase)
    NUM_EPOCHS = 5
    for epoch in range(NUM_EPOCHS):
        model.train()
        correct = total = 0
        for imgs, labels in tqdm(loader, desc=f"Epoch {epoch+1}/{NUM_EPOCHS}"):
            imgs, labels = imgs.to(device), labels.to(device)
            optimizer.zero_grad()
            outputs = model(imgs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            _, pred = torch.max(outputs, 1)
            total += labels.size(0)
            correct += (pred == labels).sum().item()
        print(f"Epoch {epoch+1} – Acc: {100*correct/total:.2f}%")

    # ------------------- Export to ONNX (embedded weights) -------------------
    model.eval()
    dummy = torch.randn(1, 3, 512, 512, device=device)
    onnx_path = "dr_resnet50.onnx"
    print("Exporting to ONNX (embedding weights)…")
    torch.onnx.export(
        model,
        dummy,
        onnx_path,
        export_params=True,
        opset_version=14,
        do_constant_folding=True,
        input_names=['input'],
        output_names=['output'],
        # IMPORTANT: embed weights, do NOT create a .onnx.data file
        use_external_data=False
    )

    # ----------- Downgrade ONNX IR version to 9 (MATLAB compatible) -----------
    print("Converting ONNX IR version to 9 for MATLAB compatibility…")
    onnx_model = onnx.load(onnx_path)
    onnx_v9 = onnx.version_converter.convert_version(onnx_model, 9)
    onnx.save(onnx_v9, "dr_resnet50_v9.onnx")
    print("Done. Use 'dr_resnet50_v9.onnx' in MATLAB.")
