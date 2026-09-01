import pandas as pd
import os
from sklearn.model_selection import train_test_split

def main():
    # Set correct paths for your local machine
    aptos_csv_path = 'datasets/1. Classification - APTOS/train.csv'
    
    if not os.path.exists(aptos_csv_path):
        print(f"Error: Could not find {aptos_csv_path}")
        return
        
    print(f"Loading data from {aptos_csv_path}...")
    df = pd.read_csv(aptos_csv_path)
    print(f"Total labeled images: {len(df)}")
    
    # Stratified Split (80% Train, 20% Val)
    # This ensures both Train and Val have the exact same percentage of each disease level
    train_df, val_df = train_test_split(df, test_size=0.2, stratify=df['diagnosis'], random_state=42)
    
    print(f"Train split: {len(train_df)} images")
    print(f"Validation split: {len(val_df)} images")
    out_dir = 'datasets/1. Classification - APTOS/splits'
    os.makedirs(out_dir, exist_ok=True)
    
    train_df.to_csv(os.path.join(out_dir, 'train_split.csv'), index=False)
    val_df.to_csv(os.path.join(out_dir, 'val_split.csv'), index=False)
    test_df.to_csv(os.path.join(out_dir, 'test_split.csv'), index=False)
    
    print(f"Splits saved to {out_dir}")

if __name__ == "__main__":
    main()
