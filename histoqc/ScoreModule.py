import logging
from numpy import nonzero
def saveRemovalStats(s, params):
    logging.info(f"{s['filename']} - \tsaveRemovalStats")
    mask = s["img_mask_use"]
    tissue = s["img_mask_bright"]
    if tissue is None:
        logging.warning(
            f"{s['filename']} - ScoreModule.saveRemovalStats requires you to run tissue detection"
        )
    #acceptable pixels divided by tissue pixels
    tissueRemaining = str(
        len(mask.nonzero()[0])/
        len((tissue == 0).nonzero()[0])
    )
    s.addToPrintList("remaining_tissue_percent", tissueRemaining)
    return