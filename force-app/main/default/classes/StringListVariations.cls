public class StringListVariations {

    // V1: Standard List<String> with for Loop
    public static List<String> generateStringList_v1_forLoop(Integer count) {
        List<String> result = new List<String>();
        for (Integer i = 0; i < count; i++) {
            result.add('Test ' + i);
        }
        return result;
    }

    // V2: Array Notation String[] with for Loop
    public static String[] generateStringList_v2_arrayNotation(Integer count) {
        String[] result = new String[] {};
        for (Integer i = 0; i < count; i++) {
            result.add('Test ' + i);
        }
        return result;
    }

    // V3: Explicit String.valueOf() Conversion
    public static List<String> generateStringList_v3_stringValueOf(Integer count) {
        List<String> stringList = new List<String>();
        for (Integer i = 0; i < count; i++) {
            stringList.add('Test ' + String.valueOf(i));
        }
        return stringList;
    }

    // V4: Fixed-Size Array Index Assignment
    public static String[] generateStringList_v4_fixedArrayIndex(Integer count) {
        String[] result = new String[count];
        for (Integer i = 0; i < count; i++) {
            result[i] = 'Test ' + i;
        }
        return result;
    }

    // V5: String.format() Placeholder Template
    public static List<String> generateStringList_v5_stringFormat(Integer count) {
        List<String> output = new List<String>();
        for (Integer i = 0; i < count; i++) {
            output.add(String.format('Test {0}', new List<String>{ String.valueOf(i) }));
        }
        return output;
    }

    // V6: while Loop
    public static List<String> generateStringList_v6_whileLoop(Integer count) {
        List<String> result = new List<String>();
        Integer i = 0;
        while (i < count) {
            result.add('Test ' + i);
            i++;
        }
        return result;
    }

    // V7: do-while Loop
    public static List<String> generateStringList_v7_doWhile(Integer count) {
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

    // V8: List Initial Capacity with Indexed Assignment
    // Note: In Apex, new List<String>(count) creates count pre-populated
    //       null entries — not just capacity like Java. Indexed assignment
    //       overwrites the nulls; .add() would double the size.
    public static List<String> generateStringList_v8_listCapacity(Integer count) {
        List<String> items = new List<String>(count);
        for (Integer i = 0; i < count; i++) {
            items[i] = 'Test ' + i;
        }
        return items;
    }

    // V9: Inline Post-Increment (counter++)
    public static List<String> generateStringList_v9_postIncrement(Integer count) {
        List<String> strings = new List<String>();
        Integer counter = 0;
        while (counter < count) {
            strings.add('Test ' + counter++);
        }
        return strings;
    }

    // V10: Private Helper Method Delegate
    public static List<String> generateStringList_v10_helperDelegate(Integer count) {
        return buildFormattedList('Test ', count);
    }

    private static List<String> buildFormattedList(String prefix, Integer count) {
        List<String> listResult = new List<String>();
        for (Integer i = 0; i < count; i++) {
            listResult.add(prefix + i);
        }
        return listResult;
    }
}