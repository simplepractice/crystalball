# Predictors

## Basic usage

[By default](https://github.com/toptal/crystalball/blob/master/lib/crystalball/rspec/runner/configuration.rb) Crystalball uses `Crystalball::RSpec::StandardPredictionBuilder` which uses
just two strategies for prediction [ModifiedExecutionPaths](#ModifiedExecutionPaths) and [ModifiedSpecs](#ModifiedSpecs).
This is more than enough for first time use.

## Advanced usage

If you want to squeeze out the most out of Crystalball you might want to add additional available prediction strategies or even add your own.
To do that you should create a class inherited from `Crystalball::RSpec::PredictionBuilder` and overload `predictor` method with your custom predictor setup similar
to what we have in [StandardPredictionBuilder](https://github.com/toptal/crystalball/blob/master/lib/crystalball/rspec/standard_prediction_builder.rb)

E.g. 
```ruby
class MyPredictionBuilder < Crystalball::RSpec::PredictionBuilder
    def predictor
      super do |p|
        p.use Crystalball::Predictor::ModifiedSpecs.new
        p.use Crystalball::Predictor::ModifiedExecutionPaths.new
        p.use Crystalball::Predictor::ModifiedSupportSpecs.new
      end
    end
end

```
creates a predictor with additional `ModifiedSupportSpecs` strategy enabled.

You also must let our runner know about your new prediction builder by adding it to configuration. Please see [runner configuration](runner.md) page for details.

### Strategies

#### AssociatedSpecs

Needs to be configured with rules for detecting which specs should be on the prediction.
```ruby
predictor.use Crystalball::Predictor::AssociatedSpecs.new(
  from: %r{models/(.*).rb}, 
  to: "./spec/models/%s_spec.rb"
  )
```
will add `./spec/models/foo_spec.rb` to prediction when `models/foo.rb` changes.
This strategy does not depend on a previously generated case map.

#### ModifiedExecutionPaths

Checks the case map and the diff to see which specs are affected by the new or modified files.

#### ModifiedSpecs

As the name implies, checks for modified specs. The scope can be modified by passing a regex as argument, which defaults to `%r{spec/.*_spec\.rb\z}`.
This strategy does not depend on a previously generated case map.

#### ModifiedSupportSpecs

Checks for modified support files used in specs and predicts full spec file. The scope can be modified by passing a regex as argument, which defaults to `%r{spec/support/.*\.rb\z}`.
Mostly usable for shared_contexts and shared_examples.

#### ModifiedSchema

Checks for modified db schema in rails application. You need to specify a path to a file with tables map generated by `TablesMapGenerator`. It checks schema diff to see which models are affected by modified tables and which specs are affected by this models.
```ruby
predictor.use Crystalball::Rails::Predictor::ModifiedSchema.new(
  tables_map_path: './tables_map.yml'
  )
```

_**Note**_: You may meet a warning like "WARNING: there are no model files for changed table ...". Usually, such tables are leftovers or a relation table for `has-and-belongs-to-many` associations. For the first case - nothing to worry about. For the second case - it means you want to change the default relation table.

### Custom strategies

As with the map generator you may define custom strategies for prediction. It must be an object that responds to `#call(diff, case_map)` (where `diff` is a `Crystalball::SourceDiff` and `case_map` is a `Crystalball::CaseMap`) and returns an array of paths.

Check out [default strategies implementation](https://github.com/toptal/crystalball/tree/master/lib/crystalball/predictor) for examples.
