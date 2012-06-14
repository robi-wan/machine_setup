# encoding: utf-8
require File.dirname(__FILE__) + "/../test_helper"

module SetupConfiguration

  module Translation

    class TranslationTest < Test::Unit::TestCase

      context "A parameter translation" do
        setup do
          I18n.backend.store_translations(:en,
                                          :parameter_distance => {:name => 'cool name', :comment => 'cooler comment'},
                                          :parameter_sensor => {:name => '', :comment => 'bazzer'},
                                          :parameter_drive => {:name => 'ice cold drive', :comment => ' ice aged  '}
          )
          @translator = Translator.new()
        end

        should "return a translation for name and description" do
          name, desc = @translator.translate(:parameter_distance, :en)
          assert_equal("cool name", name)
          assert_equal("cooler comment", desc)
        end

        should "leave whitespace around comment" do
          name, desc = @translator.translate(:parameter_drive, :en)
          assert_equal(' ice aged  ', desc)
        end

        context "with empty string as name" do
          setup do
            @key = :parameter_sensor
            I18n.backend.store_translations(:en, @key => {:name => '  ', :comment => 'bazzer'})
          end

          should "return the key as name" do
            name, desc = @translator.translate(@key, :en)
            assert_equal(@key.to_s, name)
            assert_equal("bazzer", desc)
          end
        end

        context "without entry for name" do
          setup do
            @key = :parameter_missing_name
            I18n.backend.store_translations(:en, @key => {})
          end

          should "return the key as name" do
            name, desc = @translator.translate(@key, :en)
            assert_equal(@key.to_s, name)
            assert_equal("", desc)
          end
        end

        context "with empty translation for comment" do
          setup do
            @key = :parameter_empty_comment
            I18n.backend.store_translations(:en, @key => {:comment => '     '})
          end

          should "return an empty string as description" do
            name, desc = @translator.translate(@key, :en)
            assert_equal("", desc)
          end
        end

        context "without entry for comment" do
          setup do
            @key = :parameter_missing_comment
            I18n.backend.store_translations(:en, @key => {})
          end

          should "return an empty string as description" do
            name, desc = @translator.translate(@key, :en)
            assert_equal("", desc)
          end
        end

      end

    end
  end
end
