import struct

from array import array
from enum import IntEnum
from sys import byteorder
from typing import Dict, Generator, Iterable, NamedTuple, Optional


class SignalChannel(IntEnum):
    """An enum of the IDs of a DLC pro signal channel."""

    # Special
    DEBUG = -4
    NONE = -3
    TIME = -2
    FREQUENCY = -1

    # External signals (BNC connector)
    FINE_IN1 = 0
    FINE_IN2 = 1
    FAST_IN3 = 2
    FAST_IN3B = 3
    FAST_IN4 = 4
    FAST_IN4B = 5

    OUTPUT_A = 20
    OUTPUT_B = 21

    # Internal signals (FPGA)
    LOCKIN_OUTPUT = 30
    PID1_OUTPUT = 31
    PID2_OUTPUT = 32
    SCAN_OUTPUT = 34
    SCAN_AUX_OUTPUT = 35

    # PDH signals
    PDH1_ERROR1 = 40
    PDH1_IN1 = 41
    PDH1_ERROR2 = 42
    PDH1_IN2 = 43

    PDH2_ERROR1 = 44
    PDH2_IN1 = 45
    PDH2_ERROR2 = 46
    PDH2_IN2 = 47

    # laser related signals
    DL_PIEZO_VOLTAGE = 50
    DL_CURRENT = 51
    CC_ANALOG_IN1 = 52
    CC_ANALOG_IN2 = 53
    DL_PHOTODIODE = 54
    EXTERNAL_POWER = 55
    DL_TEMP_SET = 56
    DL_TEMP_ACT = 57
    DL_EOM_VOLTAGE = 58

    AMP_CC_ANALOG_IN = 60
    AMP_SEED_POWER = 61
    AMP_POWER = 62
    AMP_CURRENT_SET = 63
    AMP_CURRENT_ACT = 64

    CTL_PHOTODIODE = 69
    CTL_POWER = 70
    CTL_MOTOR_POSITION = 71
    CTL_MODE_CONTROL = 72
    CTL_ERROR_SIGNAL = 73
    CTL_NORMALIZE_SIGNAL = 74
    CTL_INTENSITY = 75
    CTL_TONIC_Q = 76
    CTL_TONIC_I = 77
    CTL_WAVELENGTH_SET = 78
    CTL_WAVELENGTH_ACT = 79

    SHG_CAVITY_ERROR_SIGNAL = 80
    SHG_CAVITY_REJECTION_SIGNAL = 81
    SHG_INTRA_CAVITY_SIGNAL = 82
    SHG_POWER = 83

    NLO_AMP_POWER = 84
    NLO_SEED_POWER = 85
    NLO_FIBER_POWER = 86

    SHG_INPUT_POWER = 87

    SHG_CAVITY_PIEZO_VOLTAGE_SLOW = 90
    SHG_CAVITY_PIEZO_VOLTAGE_FAST = 91

    LOCK_INPUT_ALIAS = 100
    SCAN_OUTPUT_ALIAS = 101
    POWERLOCK_INPUT_ALIAS = 102
    SCAN_AUX_OUTPUT_ALIAS = 103

    FHG_CAVITY_ERROR_SIGNAL = 110
    FHG_CAVITY_REJECTION_SIGNAL = 111
    FHG_INTRA_CAVITY_SIGNAL = 112
    FHG_POWER = 113
    FHG_CAVITY_PIEZO_VOLTAGE_SLOW = 120
    FHG_CAVITY_PIEZO_VOLTAGE_FAST = 121

    UV_SHG_POWERSTAB_SETPOINT = 130

    OPO_PUMP_POWER = 144
    OPO_DEPLETED_PUMP_POWER = 145
    OPO_SIGNAL_POWER = 146
    OPO_IDLER_POWER = 147

    OPO_CAVITY_PIEZO_VOLTAGE_SLOW = 150
    OPO_CAVITY_PIEZO_VOLTAGE_FAST = 151


class DataFormatError(ValueError):
    """Exception raised for format errors in binary data.
    """


DataBlock = NamedTuple('DataBlock', [('id', str), ('payload', memoryview)])


def _binary_data_blocks(data: bytes) -> Generator[DataBlock, None, None]:
    """Generator function for the 'Scope, Lock, and Recorder Binary Data'
    format of the DLC pro that can be used to iterate over the contained
    blocks.

    Args:
        data: Input data to iterate over.

    Returns:
        A namedtuple with the following elements:
        'id': block id letter
        'payload': A memoryview with the block payload.
    """
    i = 0
    while i < len(data):
        # Block start, read block id
        blockid = data[i:i+1].decode()

        # Get payload length from zero terminated ASCII string following the
        # block id.
        try:
            header_terminator_index = data.index(0, i+1)
        except ValueError as exc:
            raise DataFormatError(f"Block header terminator not found in block '{blockid}'") from exc

        try:
            payload_len = int(data[i+1:header_terminator_index])
        except ValueError as exc:
            raise DataFormatError(f"Payload length incorrect in block '{blockid}'") from exc

        # Create payload view
        payload_start_index = header_terminator_index + 1

        if payload_start_index + payload_len > len(data):
            raise DataFormatError(f"Wrong payload size given in header of block '{blockid}'")

        payload = memoryview(data)[payload_start_index:payload_start_index + payload_len]

        i = payload_start_index + payload_len

        yield DataBlock(blockid, payload)


def _letoh(raw: array) -> array:
    """Converts the endianess of an array from little endian to host byte order.

    Args:
        raw: Instance of array with elements in little endian byte order.

    Returns:
        Instance of array with elements in host byte order.
    """
    if byteorder != 'little':
        raw.byteswap()

    return raw


def extract_float_arrays(blockids: str, data: bytes) -> Dict[str, array]:
    """Extracts float arrays from raw scope, background trace, and recorder
    zoom binary data (block ids a, A, b, B, x, y, Y in the DLC pro 'Scope,
    Lock, and Recorder Binary Data' format).

    Args:
        blockids: String of requested block id letters. Block ids not
        available in the input data or in the above list are ignored.
        data: Input byte sequence.

    Returns:
        Dictionary with found block ids as keys and arrays of floats
        (typecode 'f') as values.

    Raises:
        DataFormatError: If the contents of `data` are not conform to the
        'Scope, Lock, and Recorder Binary Data' format.
    """
    retval = {}

    for block in _binary_data_blocks(data):
        if block.id in blockids and block.id in 'aAbBxyY':
            values = array('f')  # float (IEEE 754 single precision)

            try:
                values.frombytes(block.payload.tobytes())
            except ValueError as exc:
                raise DataFormatError(f"Invalid payload length in block '{block.id}'") from exc

            retval[block.id] = _letoh(values)

    return retval


def extract_lock_points(blockids: str, data: bytes) -> Dict[str, Dict[str, Iterable]]:
    """Extracts lock points from raw lock point data (block ids l, c, t in the
    DLC pro 'Scope, Lock, and Recorder Binary Data' format).

    Args:
        blockids: String of requested block id letters. Block ids not
        available in the input data or in the above list are ignored.
        data: Input byte sequence.

    Returns:
        Dictionary with found block ids as keys with nested dicts as
        values. The nested dicts contain the keys x, y, t and lists of the
        respective field contents as values (float for keys x,y, str for key t).

    Raises:
        DataFormatError: If the contents of `data` are not conform to the
        'Scope, Lock, and Recorder Binary Data' format.
    """
    retval = {}

    for block in _binary_data_blocks(data):
        if block.id in blockids and block.id in 'clt':
            s = struct.Struct('<2f1c')

            try:
                retval[block.id] = dict([
                    ('x', list(i[0] for i in s.iter_unpack(block.payload))),
                    ('y', list(i[1] for i in s.iter_unpack(block.payload))),
                    ('t', ''.join(i[2].decode() for i in s.iter_unpack(block.payload)))
                ])
            except struct.error as exc:
                raise DataFormatError(f"Invalid payload format in block '{block.id}'") from exc

    return retval


def extract_lock_state(data: bytes) -> Optional[int]:
    """Extracts the state of the locking module from raw lock point data (block
    id s in the DLC pro 'Scope, Lock, and Recorder Binary Data' format).

    Args:
        data: Input byte sequence.

    Returns:
        Lock module's state as integer if available, otherwise None.

    Raises:
        DataFormatError: If the contents of `data` are not conform to the
        'Scope, Lock, and Recorder Binary Data' format.
    """
    for block in _binary_data_blocks(data):
        if block.id in 's':
            if len(block.payload) != 1:
                raise DataFormatError(f"Payload length incorrect in block '{block.id}'")

            return block.payload[0]

    return None
