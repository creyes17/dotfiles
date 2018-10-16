import string
import langcodes

for let1 in string.ascii_lowercase:
    for let2 in string.ascii_lowercase:
        code = let1 + let2
        autonym = langcodes.get(code).autonym()
        if autonym != code:
            print(code, autonym)
