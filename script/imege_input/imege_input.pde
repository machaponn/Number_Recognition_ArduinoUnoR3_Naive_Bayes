import processing.serial.*;

Serial port;
int predictedNumber = -1;  // 初期値として -1 を設定
String val;
long startTime;  // 送信開始時間
long elapsedTime;  // 経過時間

void setup() {
  size(280, 280);
  port = new Serial(this, "COM3", 9600); // Arduino が接続されているシリアルポートを指定
  port.bufferUntil('\n');  // 改行文字を受信するまでデータをバッファリング
  background(0);  // 黒で背景を塗りつぶす
  stroke(255);  // 白のストローク
  strokeWeight(15);  // 線の太さを20ピクセルに設定
}

void draw() {
  if (mousePressed) {
    line(pmouseX, pmouseY, mouseX, mouseY);  // マウスが押されている間、線を描く
  }

 if (port.available() > 0) {
    val = port.readStringUntil('\n');
    if (val != null) {
      print(val);
    }
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
  if (key == ' ') {  // スペースキーが押されたら
    // 画面を画像として保存
    PImage img = get(0, 0, width, height);
    img.resize(16, 16);  // 画像を16x16 にリサイズ
  
    // 画像をグレースケールに変換
    img.filter(GRAY);

    // 画像データをArduinoに送信
    img.loadPixels();
    
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        int pixelBrightness = (brightness(img.pixels[y * 16+ x]) > 128) ? 1 : 0;  // ピクセルの明るさを取得
        port.write(pixelBrightness);  // Arduinoに送信
        delay(5);
      }
    }
    port.write('\n');
  startTime = millis();
/* 
  //ピクセル値の確認用
  println("pixel: ");
  for (int y = 0; y < 16 ; y++) {
      for (int x = 0; x < 16; x++) {
        int pixelBrightness = (brightness(img.pixels[y * 16 + x]) > 128) ? 1 : 0;  // ピクセルの明るさを取得
         print(pixelBrightness);
         print(",");
      }
      println();
    }
  
*/
  }
   if (key == 'c') {
     background(0);
   }
}


void serialEvent(Serial port) {
  // シリアルポートからデータを受信
  String receivedData = port.readStringUntil('\n');
  if (receivedData != null) {
  predictedNumber = int(trim(receivedData));  // 受信データを整数に変換
  elapsedTime = millis() - startTime;  // 経過時間を計算
  }
}
