import cv2
import torch
import os
from detectron2.engine import DefaultPredictor
from detectron2.config import get_cfg
from detectron2 import model_zoo
from detectron2.utils.visualizer import Visualizer
from detectron2.data import MetadataCatalog

# ---- LOAD DETECTOR ---- #
def load_detector():
    cfg = get_cfg()
    cfg.merge_from_file(model_zoo.get_config_file(
        "COCO-Detection/faster_rcnn_R_50_FPN_3x.yaml"
    ))
    cfg.MODEL.WEIGHTS = model_zoo.get_checkpoint_url(
        "COCO-Detection/faster_rcnn_R_50_FPN_3x.yaml"
    )
    cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = 0.4  # Lower threshold?
    return DefaultPredictor(cfg)

# ---- RUN ON ONE IMAGE ---- #
def detect_and_visualize(predictor, img_path, out_path):
    im = cv2.imread(img_path)
    if im is None:
        print(f"⚠️ Cannot read {img_path}")
        return
    outputs = predictor(im)

    v = Visualizer(im[:, :, ::-1], MetadataCatalog.get("coco_2017_train"), scale=1.5)
    out = v.draw_instance_predictions(outputs["instances"].to("cpu"))
    cv2.imwrite(out_path, out.get_image()[:, :, ::-1])
    print(f"🔍 Saved: {out_path}")

# ---- MAIN ---- #
if __name__ == "__main__":
    predictor = load_detector()

    frames_dir = "data/demo/"
    debug_dir = "debug_detections"
    os.makedirs(debug_dir, exist_ok=True)

    count = 0
    for f in sorted(os.listdir(frames_dir)):
        if f.endswith(".png"):
            count += 1
            detect_and_visualize(
                predictor,
                os.path.join(frames_dir, f),
                os.path.join(debug_dir, f"debug_{f}")
            )
            if count == 3:  # Limit to first 3 frames
                break

    print("\n📌 Done! Check the debug_detections/ folder.\n")

