# Unit 1 — Completing the Hands-On Challenge

Three phases. Explore all 10 approaches, then submit.

---

## Phase 1 — Automated Tests for All 10 Variations

Two classes. All 10 methods coexist with unique names. One click runs 12 tests.

### 1a. Create `StringListVariations`

**File → New → Apex Class**, name it `StringListVariations`, clear template, paste below, Ctrl+S.

```apex
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
```

### 1b. Create `StringListVariationsTest`

**File → New → Apex Class**, name it `StringListVariationsTest`, clear template, paste below, Ctrl+S.

```apex
@isTest
private class StringListVariationsTest {

    static List<String> expected(Integer count) {
        List<String> items = new List<String>();
        for (Integer i = 0; i < count; i++) {
            items.add('Test ' + i);
        }
        return items;
    }

    static void assertMatches(String variationLabel, Integer count, List<String> actual) {
        List<String> exp = expected(count);
        System.assertEquals(exp.size(), actual.size(),
            variationLabel + ' → size mismatch');
        for (Integer i = 0; i < exp.size(); i++) {
            System.assertEquals(exp[i], actual[i],
                variationLabel + ' → item ' + i + ' mismatch');
        }
    }

    @isTest static void testV1_forLoop() { assertMatches('V1', 4, StringListVariations.generateStringList_v1_forLoop(4)); }
    @isTest static void testV2_arrayNotation() { assertMatches('V2', 4, StringListVariations.generateStringList_v2_arrayNotation(4)); }
    @isTest static void testV3_stringValueOf() { assertMatches('V3', 4, StringListVariations.generateStringList_v3_stringValueOf(4)); }
    @isTest static void testV4_fixedArrayIndex() { assertMatches('V4', 4, StringListVariations.generateStringList_v4_fixedArrayIndex(4)); }
    @isTest static void testV5_stringFormat() { assertMatches('V5', 4, StringListVariations.generateStringList_v5_stringFormat(4)); }
    @isTest static void testV6_whileLoop() { assertMatches('V6', 4, StringListVariations.generateStringList_v6_whileLoop(4)); }
    @isTest static void testV7_doWhile() { assertMatches('V7', 4, StringListVariations.generateStringList_v7_doWhile(4)); }
    @isTest static void testV8_listCapacity() { assertMatches('V8', 4, StringListVariations.generateStringList_v8_listCapacity(4)); }
    @isTest static void testV9_postIncrement() { assertMatches('V9', 4, StringListVariations.generateStringList_v9_postIncrement(4)); }
    @isTest static void testV10_helperDelegate() { assertMatches('V10', 4, StringListVariations.generateStringList_v10_helperDelegate(4)); }

    static void assertEmpty(String variationLabel, List<String> actual) {
        System.assertNotEquals(null, actual, variationLabel + ' → returned null');
        System.assertEquals(0, actual.size(), variationLabel + ' → expected empty');
    }

    @isTest
    static void testAllVariations_emptyInput() {
        assertEmpty('V1',  StringListVariations.generateStringList_v1_forLoop(0));
        assertEmpty('V2',  StringListVariations.generateStringList_v2_arrayNotation(0));
        assertEmpty('V3',  StringListVariations.generateStringList_v3_stringValueOf(0));
        assertEmpty('V4',  StringListVariations.generateStringList_v4_fixedArrayIndex(0));
        assertEmpty('V5',  StringListVariations.generateStringList_v5_stringFormat(0));
        assertEmpty('V6',  StringListVariations.generateStringList_v6_whileLoop(0));
        assertEmpty('V7',  StringListVariations.generateStringList_v7_doWhile(0));
        assertEmpty('V8',  StringListVariations.generateStringList_v8_listCapacity(0));
        assertEmpty('V9',  StringListVariations.generateStringList_v9_postIncrement(0));
        assertEmpty('V10', StringListVariations.generateStringList_v10_helperDelegate(0));
    }

    @isTest
    static void testAllVariations_singleItem() {
        assertMatches('V1',  1, StringListVariations.generateStringList_v1_forLoop(1));
        assertMatches('V2',  1, StringListVariations.generateStringList_v2_arrayNotation(1));
        assertMatches('V3',  1, StringListVariations.generateStringList_v3_stringValueOf(1));
        assertMatches('V4',  1, StringListVariations.generateStringList_v4_fixedArrayIndex(1));
        assertMatches('V5',  1, StringListVariations.generateStringList_v5_stringFormat(1));
        assertMatches('V6',  1, StringListVariations.generateStringList_v6_whileLoop(1));
        assertMatches('V7',  1, StringListVariations.generateStringList_v7_doWhile(1));
        assertMatches('V8',  1, StringListVariations.generateStringList_v8_listCapacity(1));
        assertMatches('V9',  1, StringListVariations.generateStringList_v9_postIncrement(1));
        assertMatches('V10', 1, StringListVariations.generateStringList_v10_helperDelegate(1));
    }
}
```

### 1c. Run All 12 Tests

1. **Test → New Run**.
2. Check the ☐ box next to `StringListVariationsTest` on the left. Click **Run**.
3. Tests tab opens — 12 rows, all green **Pass**.

---

## Phase 2 — Manual Anonymous Apex (Optional)

Explore one variation at a time by commenting/uncommenting in a single class.

### 2a. Paste the multi-variation class

**File → New → Apex Class**, name it `StringListTest`, clear template, paste below, Ctrl+S.

```apex
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
```

### 2b. Test each variation

**Debug → Open Execute Anonymous Window** (Ctrl+E), paste below.

**Check "Open Log"** (bottom-left), click **Execute**, then check **"Debug Only"** in the log viewer.

```apex
Integer n = 3;
List<String> output = StringListTest.generateStringList(n);

System.assertEquals(n, output.size(), 'Size mismatch');
System.assertEquals('Test 0', output[0], 'Item 0 mismatch');
System.assertEquals('Test 1', output[1], 'Item 1 mismatch');
System.assertEquals('Test 2', output[2], 'Item 2 mismatch');

List<String> empty = StringListTest.generateStringList(0);
System.assertEquals(0, empty.size(), 'Empty size mismatch');
System.assertNotEquals(null, empty, 'Should not be null');

System.debug('All assertions passed.');
```

Expected output:

```
USER_DEBUG | (Test 0, Test 1, Test 2)
USER_DEBUG | All assertions passed.
```

### 2c. Cycle through variations

Only one `generateStringList` visible at a time.

| Var | Action |
|-----|--------|
| V1 | Already active. Run test. |
| V2 | Wrap V1 in `/* */`, remove `/* */` from V2, save, run test. |
| V3 | Re-wrap V2, uncomment V3, save, run test. |
| … | Repeat through V10. |

---

## Phase 3 — Submit the Trailhead Answer

Replace `StringListTest` with the clean single-variation class.

**Open `StringListTest`**, Ctrl+A, delete, paste below, Ctrl+S.

```apex
public class StringListTest {
    public static List<String> generateStringList(Integer count) {
        List<String> result = new List<String>();
        for (Integer i = 0; i < count; i++) {
            result.add('Test ' + i);
        }
        return result;
    }
}
```

Run the Anonymous Apex test from Phase 2b to confirm. Then click **Check Challenge** in Trailhead.
