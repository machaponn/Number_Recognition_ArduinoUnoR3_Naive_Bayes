import processing.serial.*;
import java.nio.ByteBuffer;
import java.util.ArrayList;

Serial port;
int predictedNumber = -1;  // 初期値として -1 を設定
String val;
long startTime;  // 送信開始時間
long elapsedTime;  // 経過時間
ArrayList<Long> times = new ArrayList<>();  // 計測時間のリスト
int totalTests = 1000;  // テストする画像の枚数
int correctCount = 0;  // 正答数
int currentTest = 0;  // 現在のテスト番号
int[] mistakes = new int[totalTests];  // 間違えた画像のインデックス

//MNISTテストデータの読み込み用
byte[] images;
byte[] labels;

void setup() {
  String testImage = "t10k-images.idx3-ubyte";
  String testLabel = "t10k-labels.idx1-ubyte";
  
  // MNISTテストデータのバイナリファイルを読み込み
  images = loadBytes(testImage);
  labels = loadBytes(testLabel);
  
  size(280, 280);
  port = new Serial(this, "COM4", 9600); // Arduino が接続されているシリアルポートを指定
  port.bufferUntil('\n');  // 改行文字を受信するまでデータをバッファリング
  background(0);  // 黒で背景を塗りつぶす
  stroke(255);  // 白のストローク
  strokeWeight(15);  // 線の太さを15ピクセルに設定
}

void draw() {
  if (mousePressed) {
    line(pmouseX, pmouseY, mouseX, mouseY);  // マウスが押されている間、線を描く
  }

  textSize(32);
  textAlign(CENTER, CENTER);
  if (predictedNumber != -1) {
    fill(255);
    text("Predicted Number: " + predictedNumber, width / 2, height - 25);  // 予測結果を表示
    text("Elapsed Time: " + elapsedTime + " ms", width / 2, height - 75);  // 経過時間を表示
    println("predicted: " + predictedNumber);
    predictedNumber = -1;
  }
}


void keyPressed() { 
  if (key == 't') {
    testImages();
  }
  
  if (key == 'c') {
    background(0);
  }
  
  if (key == 'r') {
    currentTest = 0;
    correctCount = 0;
    times.clear();
    background(0);
  }
}

// テスト画像を送信して結果を表示する関数
void testImages() {
  if (currentTest < totalTests) {
    PImage img = loadImage(currentTest); // MNISTテストデータの画像を1枚抽出

    // 画像データをArduinoに送信
    img.loadPixels();
    startTime = millis();  // 送信開始時間を記録
    for (int y = 0; y < 28; y++) {
      for (int x = 0; x < 28; x++) {
        int pixelBrightness = (brightness(img.pixels[y * 28 + x]) > 128) ? 1 : 0;  // ピクセルの明るさを取得
        port.write(pixelBrightness);  // Arduinoに送信
        delay(5);
      }
    }
    port.write('\n');
  } else {
    // テスト終了後に結果を表示
    displayResults();
  }
}

// テスト結果を表示する関数
void displayResults() {
  float accuracy = (float) correctCount / totalTests * 100;
  float avgTime = (float) sum(times) / times.size();

  println("Total Tests: " + totalTests);
  println("Correct: " + correctCount);
  println("Accuracy: " + accuracy + "%");
  println("Average Time: " + avgTime + " ms");
  println("Mistakes:");
  for (int i = 0; i < totalTests; i++) {
    if (mistakes[i] != 0) {
      println("Index: " + i + ", Predicted: " + mistakes[i] + ", Actual: " + (labels[17 + i] & 0xFF));
    }
  }
}

// リストの合計を計算する関数
long sum(ArrayList<Long> list) {
  long sum = 0;
  for (long num : list) {
    sum += num;
  }
  return sum;
}

//MNISTテストデータの読み込み用
// MNISTテストデータの画像を抽出する関数
PImage loadImage(int index) {
  int skipByte = 16 + index * 784; // ヘッダと読み込んだ画像のピクセルデータを飛ばす

  // バイナリファイルを画像データに変換
  PImage img = createImage(28, 28, GRAY);
  for (int i = 0; i < 28 * 28; i++) {
    int value = images[i + skipByte] & 0xFF;  // バイトを0-255の範囲に変換
    img.pixels[i] = color(value);  // グレースケールの値を設定
  }
  
  img.updatePixels();
  image(img, 0, 0, width, height); // 描画エリアに28x28の画像を拡大表示
    
  return img;
}

//Arduinoとの通信確認するときは以下のコードをコメントアウト

void serialEvent(Serial port) {
  // シリアルポートからデータを受信
  String receivedData = port.readStringUntil('\n');
  if (receivedData != null) {
    predictedNumber = int(trim(receivedData));  // 受信データを整数に変換
    elapsedTime = millis() - startTime;  // 経過時間を計算
    times.add(elapsedTime);  // 経過時間をリストに追加

    int actualNumber = labels[16 + currentTest] & 0xFF;  // 実際のラベル
    if (predictedNumber == actualNumber) {
      correctCount++;  // 正答の場合
    } else {
      mistakes[currentTest] = predictedNumber;  // 間違えた場合
    }
    
    currentTest++;
    testImages();  // 次のテスト画像を送信
  }
}
