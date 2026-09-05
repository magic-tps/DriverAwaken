# Integracion Flutter - MagicDrive Alert Fase 2

Esta carpeta contiene los assets generados por el pipeline Python:

- `assets/models/drowsiness_mlp.tflite`
- `assets/models/preprocessing_metadata.json`

## Donde copiarlos

Copia la carpeta `assets/models/` dentro del proyecto Flutter, por ejemplo:

```text
driveawake/
  assets/
    models/
      drowsiness_mlp.tflite
      preprocessing_metadata.json
```

## pubspec.yaml

Agrega los assets:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/models/drowsiness_mlp.tflite
    - assets/models/preprocessing_metadata.json
```

## Dependencia sugerida

```yaml
dependencies:
  tflite_flutter: ^0.11.0
```

## Orden exacto de features

Flutter debe enviar las features en este orden exacto:

1. `face_ratio`
2. `no_face_ratio`
3. `ear_mean`
4. `ear_min`
5. `ear_max`
6. `ear_std`
7. `mar_mean`
8. `mar_max`
9. `mar_std`
10. `perclos`
11. `blink_count`
12. `max_eye_closed_duration`
13. `yawn_count`
14. `yawn_ratio`
15. `yaw_proxy_mean`
16. `yaw_proxy_max_abs`
17. `pitch_proxy_mean`
18. `pitch_proxy_max`
19. `valid_frame_count`
20. `total_frame_count`
21. `valid_frame_ratio`
22. `invalid_frame_count`
23. `ear_range`
24. `ear_mean_to_min_gap`
25. `ear_closed_intensity_mean`
26. `ear_closed_intensity_min`
27. `ear_stability_ratio`
28. `mar_open_intensity_mean`
29. `mar_open_intensity_max`
30. `mar_activity_ratio`
31. `blink_rate`
32. `yawn_rate`
33. `closed_duration_ratio`
34. `closed_frames_estimated`
35. `head_yaw_abs_mean_proxy`
36. `head_pitch_abs_mean_proxy`
37. `head_pose_intensity`
38. `fatigue_eye_score`
39. `fatigue_mouth_score`
40. `fatigue_pose_score`
41. `fatigue_combined_score`
42. `perclos_x_yawn_ratio`
43. `perclos_x_closed_duration`
44. `perclos_x_head_pose`
45. `mar_x_head_pose`
46. `blink_per_valid_frame`
47. `yawn_per_valid_frame`
48. `ear_mean_diff1`
49. `ear_mean_abs_diff1`
50. `ear_min_diff1`
51. `ear_min_abs_diff1`
52. `mar_mean_diff1`
53. `mar_mean_abs_diff1`
54. `mar_max_diff1`
55. `mar_max_abs_diff1`
56. `perclos_diff1`
57. `perclos_abs_diff1`
58. `yaw_proxy_mean_diff1`
59. `yaw_proxy_mean_abs_diff1`
60. `pitch_proxy_mean_diff1`
61. `pitch_proxy_mean_abs_diff1`
62. `face_ratio_roll3_mean`
63. `face_ratio_roll3_max`
64. `face_ratio_roll3_min`
65. `no_face_ratio_roll3_mean`
66. `no_face_ratio_roll3_max`
67. `no_face_ratio_roll3_min`
68. `ear_mean_roll3_mean`
69. `ear_mean_roll3_max`
70. `ear_mean_roll3_min`
71. `ear_min_roll3_mean`
72. `ear_min_roll3_max`
73. `ear_min_roll3_min`
74. `ear_std_roll3_mean`
75. `ear_std_roll3_max`
76. `ear_std_roll3_min`
77. `mar_mean_roll3_mean`
78. `mar_mean_roll3_max`
79. `mar_mean_roll3_min`
80. `mar_max_roll3_mean`
81. `mar_max_roll3_max`
82. `mar_max_roll3_min`
83. `perclos_roll3_mean`
84. `perclos_roll3_max`
85. `perclos_roll3_min`
86. `max_eye_closed_duration_roll3_mean`
87. `max_eye_closed_duration_roll3_max`
88. `max_eye_closed_duration_roll3_min`
89. `yawn_ratio_roll3_mean`
90. `yawn_ratio_roll3_max`
91. `yawn_ratio_roll3_min`
92. `yaw_proxy_max_abs_roll3_mean`
93. `yaw_proxy_max_abs_roll3_max`
94. `yaw_proxy_max_abs_roll3_min`
95. `pitch_proxy_max_roll3_mean`
96. `pitch_proxy_max_roll3_max`
97. `pitch_proxy_max_roll3_min`
98. `blink_count_roll3_sum`
99. `yawn_count_roll3_sum`
100. `face_ratio_roll6_mean`
101. `face_ratio_roll6_max`
102. `face_ratio_roll6_min`
103. `no_face_ratio_roll6_mean`
104. `no_face_ratio_roll6_max`
105. `no_face_ratio_roll6_min`
106. `ear_mean_roll6_mean`
107. `ear_mean_roll6_max`
108. `ear_mean_roll6_min`
109. `ear_min_roll6_mean`
110. `ear_min_roll6_max`
111. `ear_min_roll6_min`
112. `ear_std_roll6_mean`
113. `ear_std_roll6_max`
114. `ear_std_roll6_min`
115. `mar_mean_roll6_mean`
116. `mar_mean_roll6_max`
117. `mar_mean_roll6_min`
118. `mar_max_roll6_mean`
119. `mar_max_roll6_max`
120. `mar_max_roll6_min`
121. `perclos_roll6_mean`
122. `perclos_roll6_max`
123. `perclos_roll6_min`
124. `max_eye_closed_duration_roll6_mean`
125. `max_eye_closed_duration_roll6_max`
126. `max_eye_closed_duration_roll6_min`
127. `yawn_ratio_roll6_mean`
128. `yawn_ratio_roll6_max`
129. `yawn_ratio_roll6_min`
130. `yaw_proxy_max_abs_roll6_mean`
131. `yaw_proxy_max_abs_roll6_max`
132. `yaw_proxy_max_abs_roll6_min`
133. `pitch_proxy_max_roll6_mean`
134. `pitch_proxy_max_roll6_max`
135. `pitch_proxy_max_roll6_min`
136. `blink_count_roll6_sum`
137. `yawn_count_roll6_sum`
138. `face_ratio_roll12_mean`
139. `face_ratio_roll12_max`
140. `face_ratio_roll12_min`
141. `no_face_ratio_roll12_mean`
142. `no_face_ratio_roll12_max`
143. `no_face_ratio_roll12_min`
144. `ear_mean_roll12_mean`
145. `ear_mean_roll12_max`
146. `ear_mean_roll12_min`
147. `ear_min_roll12_mean`
148. `ear_min_roll12_max`
149. `ear_min_roll12_min`
150. `ear_std_roll12_mean`
151. `ear_std_roll12_max`
152. `ear_std_roll12_min`
153. `mar_mean_roll12_mean`
154. `mar_mean_roll12_max`
155. `mar_mean_roll12_min`
156. `mar_max_roll12_mean`
157. `mar_max_roll12_max`
158. `mar_max_roll12_min`
159. `perclos_roll12_mean`
160. `perclos_roll12_max`
161. `perclos_roll12_min`
162. `max_eye_closed_duration_roll12_mean`
163. `max_eye_closed_duration_roll12_max`
164. `max_eye_closed_duration_roll12_min`
165. `yawn_ratio_roll12_mean`
166. `yawn_ratio_roll12_max`
167. `yawn_ratio_roll12_min`
168. `yaw_proxy_max_abs_roll12_mean`
169. `yaw_proxy_max_abs_roll12_max`
170. `yaw_proxy_max_abs_roll12_min`
171. `pitch_proxy_max_roll12_mean`
172. `pitch_proxy_max_roll12_max`
173. `pitch_proxy_max_roll12_min`
174. `blink_count_roll12_sum`
175. `yawn_count_roll12_sum`
176. `perclos_minus_roll3`
177. `perclos_minus_roll6`
178. `ear_mean_minus_roll3`
179. `mar_max_minus_roll3`
180. `fatigue_accumulation_3`
181. `fatigue_accumulation_6`

## Preprocesamiento que debe replicar Flutter

1. Construir el vector con el orden anterior.
2. Si una feature es NaN o no esta disponible, reemplazarla por la mediana de `imputer_medians`.
3. Normalizar cada valor:

```text
valor_normalizado = (valor - scaler_means[i]) / scaler_stds[i]
```

4. Enviar un tensor `[1, feature_count]` de `float32` al modelo TFLite.
5. Leer la salida softmax `[1, 3]`.

## Features temporales

Este modelo puede incluir features enriquecidas como:

- diferencias contra la ventana anterior (`*_diff1`)
- promedios/maximos/minimos rolling de 3, 6 y 12 ventanas
- acumuladores de fatiga basados en ojos, boca y pose

Para producirlas en Flutter, manten un buffer por sesion de conduccion con las
ultimas ventanas de 10 segundos. Al iniciar una sesion, calcula las rolling
features con las ventanas disponibles; para la primera ventana los deltas deben
ser `0`, igual que en el entrenamiento.

## Interpretacion de salida

- Indice `0`: despierto
- Indice `1`: cansancio
- Indice `2`: somnoliento

Uso recomendado en la app:

- Si ojos cerrados mas de 3 segundos: alarma por regla critica.
- Si no hay rostro mas de 2 segundos: alerta por regla critica.
- Si el modelo predice `somnoliento` con alta confianza: alarma o elevacion de riesgo.
- Si el modelo predice `cansancio`: combinar con PERCLOS, bostezos y cabeza caida.
