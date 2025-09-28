import datetime
import time

# --- LANKA TIME CONSTANTS ---
# Standard time system:
SECONDS_IN_KALA = 48
SECONDS_IN_DAY = 24 * 60 * 60  # 86400

# Total Kalas in a standard day (86400 / 48)
KALAS_IN_DAY = SECONDS_IN_DAY // SECONDS_IN_KALA  # 1800

def get_lanka_time():
    """
    Calculates the current real-world UTC time and the corresponding Lanka Time.
    Lanka Time Units: Varsam (Year), Dinam (Day of Year), Kala (48-second unit).
    All Lanka Time units are expressed in Hexadecimal.
    """
    # 1. Get current time in UTC (Lanka's implied standard)
    now_utc = datetime.datetime.now(datetime.UTC)
    
    # --- REAL-WORLD UTC TIME ---
    utc_time_str = now_utc.strftime("%Y-%m-%d %H:%M:%S UTC")

    # --- LANKA TIME CALCULATION ---
    
    # 2. Varsam (Year) - Decimal year to Hex
    varsam_decimal = now_utc.year
    varsam_hex = hex(varsam_decimal).upper().replace("0X", "")
    
    # 3. Dinam (Day of Year) - Decimal day (1 to 365/366) to Hex
    # Note: st_mday starts at 1
    dinam_decimal = now_utc.timetuple().tm_yday
    dinam_hex = hex(dinam_decimal).upper().replace("0X", "")
    
    # 4. Kala (Time of Day in 48-second units) - Decimal to Hex
    
    # Calculate seconds passed since the start of the current Dinam (midnight)
    seconds_since_midnight = (
        now_utc.hour * 3600 +
        now_utc.minute * 60 +
        now_utc.second
    )
    
    # Convert seconds to Kalas (48-second units)
    # The result is the current Kala count since midnight.
    current_kala_decimal = seconds_since_midnight // SECONDS_IN_KALA
    
    # Format the Kala value as a 3-digit Hex string (since max is 708)
    kala_hex = hex(current_kala_decimal).upper().replace("0X", "")
    kala_hex_padded = kala_hex.zfill(3)

    # 5. Assemble Lanka Time string
    lanka_time_str = (
        f"Varsam {varsam_hex}, "
        f"Dinam {dinam_hex}, "
        f"Kala {kala_hex_padded}"
    )

    # --- OUTPUT ---
    return utc_time_str, lanka_time_str

# Run the calculation and print the results
current_utc, current_lanka = get_lanka_time()

print("--- Current Time Readings ---")
print(f"Real-World (UTC): {current_utc}")
print(f"Lanka Time:       {current_lanka}")

# --- EXAMPLE OF MAX KALA VALUE (FOR REFERENCE) ---
# print(f"\nMax Kala Value (Decimal): {KALAS_IN_DAY}")
# print(f"Max Kala Value (Hex):     {hex(KALAS_IN_DAY).upper().replace('0X', '')}") 
# Max Kala is 1800 (decimal) or 708 (hex)
