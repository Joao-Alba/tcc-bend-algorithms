def u24_to_seconds(high: int, low: int) -> float:
    timestamp_ns = (high << 24) | low
    timestamp_seconds = timestamp_ns / 1_000_000_000
    return timestamp_seconds

high, low = 7396, 6347477
seconds = u24_to_seconds(high, low)
print(f"Timestamp in seconds: {seconds}")
