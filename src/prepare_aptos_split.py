import pandas as pd
import os
from sklearn.model_selection import train_test_split

def main():
    aptos_csv_path = 'datasets/classification/aptos2019/train.csv'
    if not os.path.exists(aptos_csv_path):
        print(f"Error: {aptos_csv_path} not found.")
        return

    df = pd.read_csv(aptos_csv_path)
    print(f"Total labeled images: {len(df)}")
    
    # 70% train, 30% temp (for val/test)
    train_df, temp_df = train_test_split(df, test_size=0.3, random_state=42, stratify=df['diagnosis'])
    
    # Split temp into 50% val, 50% test (so 15% val, 15% test of total)
    val_df, test_df = train_test_split(temp_df, test_size=0.5, random_state=42, stratify=temp_df['diagnosis'])
    
    print(f"Train split: {len(train_df)} images")
    print(f"Validation split: {len(val_df)} images")
    print(f"Test split: {len(test_df)} images")
    
    out_dir = 'datasets/classification/aptos2019/splits'
    os.makedirs(out_dir, exist_ok=True)
    
    train_df.to_csv(os.path.join(out_dir, 'train_split.csv'), index=False)
    val_df.to_csv(os.path.join(out_dir, 'val_split.csv'), index=False)
    test_df.to_csv(os.path.join(out_dir, 'test_split.csv'), index=False)
    
    print(f"Splits saved to {out_dir}")

if __name__ == "__main__":
    main()
