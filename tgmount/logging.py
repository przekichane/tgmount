import logging


def init_logging(debug=False):
    logging.basicConfig(
        format='%(asctime)s\t%(levelname)s\t[%(name)s]\t%(message)s',
        level=logging.DEBUG if debug else logging.INFO,
        handlers=[
            logging.StreamHandler()
        ]
    )

    logging.getLogger('tgvfs').setLevel(logging.DEBUG if debug else logging.INFO)
    logging.getLogger('tgclient').setLevel(logging.DEBUG if debug else logging.INFO)
    logging.getLogger('telethon').setLevel(logging.INFO if debug else logging.ERROR)

