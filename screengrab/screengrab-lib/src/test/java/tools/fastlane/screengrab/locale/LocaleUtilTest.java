package tools.fastlane.screengrab.locale;

import org.junit.Test;

import java.util.Locale;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

/**
 * To work on unit tests, switch the Test Artifact in the Build Variants view.
 */
public class LocaleUtilTest {

    @Test
    public void testLocaleFromParts_ignores4thPart() {
        assertEquals(new Locale("ja", "JP", "JP"), LocaleUtil.localeFromParts(new String[]{"ja", "JP", "JP", "junk"}));
    }

    @Test
    public void testLocaleFromParts_threeParts() {
        assertEquals(new Locale ("ja", "JP", "JP"), LocaleUtil.localeFromParts(new String[]{"ja", "JP", "JP"}));
    }

    @Test
    public void testLocaleFromParts_twoParts() {
        assertEquals(Locale.CANADA_FRENCH, LocaleUtil.localeFromParts(new String[]{"fr", "CA"}));
    }

    @Test
    public void testLocaleFromParts_onePart() {
        assertEquals(Locale.FRENCH, LocaleUtil.localeFromParts(new String[]{"fr"}));
    }

    @Test
    public void testLocaleFromParts_nullNoParts() {
        assertNull(LocaleUtil.localeFromParts(new String[]{}));
    }

    @Test
    public void testLocaleFromParts_nullFromNull() {
        assertNull(LocaleUtil.localeFromParts(null));
    }

    @Test
    public void testlocalePartsFrom_twoParts() {
        assertArrayEquals(new String[]{"fr", "CA"}, LocaleUtil.localePartsFrom("fr_CA"));
    }

    @Test
    public void testlocalePartsFrom_onePart() {
        assertArrayEquals(new String[]{"fr"}, LocaleUtil.localePartsFrom("fr"));
    }

    @Test
    public void testlocalePartsFrom_fromNull() {
        assertNull(LocaleUtil.localePartsFrom(null));
    }

}
