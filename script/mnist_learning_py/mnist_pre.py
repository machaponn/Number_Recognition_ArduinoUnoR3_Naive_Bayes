import torch
import torchvision
from torchvision import datasets, transforms
import numpy as np

# データセットのダウンロードとトランスフォームの設定
transform = transforms.Compose([
    transforms.Resize((16, 16)),  # 画像を16x16にリサイズ
    transforms.ToTensor(),
    transforms.Lambda(lambda x: (x > 0.5).float())  # 二値化
])

# 訓練データとテストデータの読み込み
train_dataset = datasets.MNIST(root='./data', train=True, download=True, transform=transform)
test_dataset = datasets.MNIST(root='./data', train=False, download=True, transform=transform)

# DataLoaderの設定
train_loader = torch.utils.data.DataLoader(train_dataset, batch_size=len(train_dataset), shuffle=True)
test_loader = torch.utils.data.DataLoader(test_dataset, batch_size=len(test_dataset), shuffle=False)

# DataLoaderから全データを取得
train_images, train_labels = next(iter(train_loader))
test_images, test_labels = next(iter(test_loader))

# データをnumpy配列に変換
train_images = train_images.numpy().reshape(-1, 16*16)
test_images = test_images.numpy().reshape(-1, 16*16)

# ラベルをnumpy配列に変換
train_labels = train_labels.numpy()
test_labels = test_labels.numpy()

# データの保存
np.save('train_images.npy', train_images)
np.save('train_labels.npy', train_labels)
np.save('test_images.npy', test_images)
np.save('test_labels.npy', test_labels)
