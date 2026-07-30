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