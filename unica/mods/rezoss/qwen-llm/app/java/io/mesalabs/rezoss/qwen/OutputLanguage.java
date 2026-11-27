package io.mesalabs.rezoss.qwen;

/**
 * Pick the language a summary must be written in from the script the messages are written in.
 * "Match the source language" is not enough on its own: notification text mixes the message with
 * English app titles, channel names, handles and links, and next to an all-English instruction the
 * model then answers in English. A Hangul syllable or a kana/Han character carries about as much as
 * three Latin letters, so weight those scripts before comparing.
 */
final class OutputLanguage {
    private OutputLanguage() { }

    static String of(String input) {
        if (input == null) return null;
        String text = input.replaceAll("(?i)\\b(?:https?://|www\\.)\\S+", " ").replaceAll("[@#]\\S+", " ");
        int latin = 0, hangul = 0, kana = 0, han = 0, thai = 0, arabic = 0, cyrillic = 0;
        for (int i = 0; i < text.length(); ) {
            int cp = text.codePointAt(i); i += Character.charCount(cp);
            if (!Character.isLetter(cp)) continue;
            switch (Character.UnicodeScript.of(cp)) {
                case LATIN: latin++; break;
                case HANGUL: hangul++; break;
                case HIRAGANA: case KATAKANA: kana++; break;
                case HAN: han++; break;
                case THAI: thai++; break;
                case ARABIC: arabic++; break;
                case CYRILLIC: cyrillic++; break;
                default: break;
            }
        }
        int total = latin + 3 * (hangul + kana + han) + thai + arabic + cyrillic;
        if (total < 6) return null;
        if (4 * 3 * hangul >= total) return "Korean";
        if (kana > 0 && 4 * 3 * (kana + han) >= total) return "Japanese";
        if (4 * 3 * han >= total) return "Chinese";
        if (3 * thai >= total) return "Thai";
        if (3 * arabic >= total) return "Arabic";
        return null;
    }

    /** Sentence to add to a summary instruction, or "" to keep the model's own judgement. */
    static String rule(String input) {
        String language = of(input);
        return language == null ? "" : " Write the summary in " + language
                + ", even where names, handles, app titles or links are in another language.";
    }
}
