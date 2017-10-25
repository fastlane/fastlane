package screengrab;

import org.junit.Test;

import java.util.Locale;

import screengrab.locale.LocaleUtil;

import static org.junit.Assert.*;

/**
 * To work on unit tests, switch the Test Artifact in the Build Variants view.
 */
public class LocaleUtilTest {

    @Test
    public void testLocaleFromParts_ignores4thPart() throws Exception {
        assertEquals(new Locale("ja", "JP", "JP"), LocaleUtil.localeFromParts(new String[]{"ja", "JP", "JP", "junk"}));
    }

    @Test
    public void testLocaleFromParts_threeParts() throws Exception {
        assertEquals(new Locale ("ja", "JP", "JP"), LocaleUtil.localeFromParts(new String[]{"ja", "JP", "JP"}));
    }

    @Test
    public void testLocaleFromParts_twoParts() throws Exception {
        assertEquals(Locale.CANADA_FRENCH, LocaleUtil.localeFromParts(new String[]{"fr", "CA"}));
    }

    @Test
    public void testLocaleFromParts_onePart() throws Exception {
        assertEquals(Locale.FRENCH, LocaleUtil.localeFromParts(new String[]{"fr"}));
    }

    @Test
    public void testLocaleFromParts_nullNoParts() throws Exception {
        assertNull(LocaleUtil.localeFromParts(new String[]{}));
    }

    @Test
    public void testLocaleFromParts_nullFromNull() throws Exception {
        assertNull(LocaleUtil.localeFromParts(null));
    }

    @Test
    public void testlocalePartsFrom_twoParts() throws Exception {
        assertArrayEquals(new String[]{"fr", "CA"}, LocaleUtil.localePartsFrom("fr_CA"));
    }

    @Test
    public void testlocalePartsFrom_onePart() throws Exception {
        assertArrayEquals(new String[]{"fr"}, LocaleUtil.localePartsFrom("fr"));
    }

    @Test
    public void testlocalePartsFrom_fromNull() throws Exception {
        assertNull(LocaleUtil.localePartsFrom(null));
    }

}
