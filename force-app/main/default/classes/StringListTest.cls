/*
 * Variation 1 is ACTIVE. To test another, comment out V1
 * and remove the opening and closing comment wrappers from the next.
 */

public class StringListTest {

    // =========================================================================
    // VARIATION 1: Standard List<String> with for Loop (ACTIVE)
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> result = new List<String>();
        for (Integer i = 0; i < count; i++) {
            result.add('Test ' + i);
        }
        return result;
    }

    /*
    // =========================================================================
    // VARIATION 2: Array Notation String[] with for Loop
    // =========================================================================
    public static String[] generateStringList(Integer count) {
        String[] result = new String[] {};
        for (Integer i = 0; i < count; i++) {
            result.add('Test ' + i);
        }
        return result;
    }
    */

    /*
    // =========================================================================
    // VARIATION 3: Explicit String.valueOf() Conversion
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> stringList = new List<String>();
        for (Integer i = 0; i < count; i++) {
            stringList.add('Test ' + String.valueOf(i));
        }
        return stringList;
    }
    */

    /*
    // =========================================================================
    // VARIATION 4: Fixed-Size Array Index Assignment
    // =========================================================================
    public static String[] generateStringList(Integer count) {
        String[] result = new String[count];
        for (Integer i = 0; i < count; i++) {
            result[i] = 'Test ' + i;
        }
        return result;
    }
    */

    /*
    // =========================================================================
    // VARIATION 5: String.format() Placeholder Template
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> output = new List<String>();
        for (Integer i = 0; i < count; i++) {
            output.add(String.format('Test {0}', new List<String>{ String.valueOf(i) }));
        }
        return output;
    }
    */

    /*
    // =========================================================================
    // VARIATION 6: while Loop
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> result = new List<String>();
        Integer i = 0;
        while (i < count) {
            result.add('Test ' + i);
            i++;
        }
        return result;
    }
    */

    /*
    // =========================================================================
    // VARIATION 7: do-while Loop
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> result = new List<String>();
        Integer i = 0;
        if (count > 0) {
            do {
                result.add('Test ' + i);
                i++;
            } while (i < count);
        }
        return result;
    }
    */

    /*
    // =========================================================================
    // VARIATION 8: List Initial Capacity with Indexed Assignment
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> items = new List<String>(count);
        for (Integer i = 0; i < count; i++) {
            items[i] = 'Test ' + i;
        }
        return items;
    }
    */

    /*
    // =========================================================================
    // VARIATION 9: Inline Post-Increment (counter++)
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> strings = new List<String>();
        Integer counter = 0;
        while (counter < count) {
            strings.add('Test ' + counter++);
        }
        return strings;
    }
    */

    /*
    // =========================================================================
    // VARIATION 10: Private Helper Method Delegate
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        return buildFormattedList('Test ', count);
    }

    private static List<String> buildFormattedList(String prefix, Integer count) {
        List<String> listResult = new List<String>();
        for (Integer i = 0; i < count; i++) {
            listResult.add(prefix + i);
        }
        return listResult;
    }
    */
}