require 'strscan'
require 'minitest/autorun'

class StringScannerTest < Minitest::Test
  def test_hello_world
    text = 'Hello, world!'
    scanner = StringScanner.new(text)

    assert_equal true, scanner.bol?
    assert_equal false, scanner.eos?

    assert_equal 'Hello', scanner.scan(/[[:word:]]+/)
    assert_equal ', world!', scanner.rest

    assert_equal true, scanner.match?(/[[:word:]+]/).nil?
    assert_equal 1, scanner.match?(/,/)

    assert_equal 2, scanner.skip_until(/[[:space:]]/)
    assert_equal 'world!', scanner.rest

    assert_equal 6, scanner.skip(/[[:word:]]+!/)
    assert_equal '', scanner.rest

    assert_equal true, scanner.eos?
  end

  def test_bluesky_post
    text = '[リンゴ] 今日は `シナノドルチェ` を食べた。パリッとした食感で、果汁があふれ出た。酸味と甘味がしっかりとあっておいしかった。'
    scanner = StringScanner.new(text)

    # スキャンポインタを進めつつ、 "[リンゴ]" 始まりかを確認
    unless scanner.skip(/\[リンゴ\]/)
      raise 'リンゴの投稿ではない'
    end

    # リンゴ名の前まで移動
    unless scanner.skip(/[[:space:]]*[[:word:]]+[[:space:]]`/)
      raise 'リンゴ名がなさそう'
    end

    # リンゴ名を取得
    unless scanner.match?(/[[:word:]]+`/)
      raise 'やっぱりリンゴ名がなさそう'
    end
    apple_name = scanner.scan(/[[:word:]]+/)

    # 感想文の前まで移動
    unless scanner.skip(/`[[:space:]]*[[:word:]]+[[:space:]]*。/)
      raise 'リンゴ名の一文が終わってなさそう'
    end

    # 感想を取得
    impression = scanner.scan(/[[[:word:]]|[[:punct:]]]+/)
    assert_equal true, scanner.eos?

    assert_equal 'シナノドルチェ', apple_name
    assert_equal 'パリッとした食感で、果汁があふれ出た。酸味と甘味がしっかりとあっておいしかった。', impression
  end
end
