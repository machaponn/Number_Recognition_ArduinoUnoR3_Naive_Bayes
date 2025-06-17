import numpy as np

class_log_prior_ = np.load('class_log_prior_.npy')
feature_log_prob_ = np.load('feature_log_prob_.npy')

with open('nb_weights.h', 'w') as f:
    f.write('#ifndef NB_WEIGHTS_H\n')
    f.write('#define NB_WEIGHTS_H\n\n')

    # 事前確率の対数を書き込む
    f.write('const float class_log_prior[10] PROGMEM = {')
    f.write(', '.join([f'{x:.7f}' for x in class_log_prior_]))
    f.write('};\n\n')

    # 特徴ベクトルの対数確率を書き込む
    f.write('const float feature_log_prob[10][256] PROGMEM = {\n')
    for c in range(10):
        f.write('    {')
        f.write(', '.join([f'{x:.4f}' for x in feature_log_prob_[c]]))
        f.write('},\n')
    f.write('};\n\n')

    f.write('#endif\n')
