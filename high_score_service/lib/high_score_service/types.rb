# frozen_string_literal: true

# WARNING ABOUT GENERATED CODE
#
# This file was code generated using smithy-ruby.
# https://github.com/awslabs/smithy-ruby
#
# WARNING ABOUT GENERATED CODE

module HighScoreService
  module Types

    HighScoreAttributes = Struct.new(
      :id,
      :game,
      :score,
      :created_at,
      :updated_at,
      keyword_init: true
    ) { include Seahorse::Structure }

    HighScoreParams = Struct.new(
      :game,
      :score,
      keyword_init: true
    ) { include Seahorse::Structure }

    UnprocessableEntityError = Struct.new(
      :errors,
      keyword_init: true
    ) { include Seahorse::Structure }

    CreateHighScoreInput = Struct.new(
      :high_score,
      keyword_init: true
    ) { include Seahorse::Structure }

    CreateHighScoreOutput = Struct.new(
      :high_score,
      :location,
      keyword_init: true
    ) { include Seahorse::Structure }

    DeleteHighScoreInput = Struct.new(
      :id,
      keyword_init: true
    ) { include Seahorse::Structure }

    DeleteHighScoreOutput = Struct.new(
      nil,
      keyword_init: true
    ) { include Seahorse::Structure }

    GetHighScoreInput = Struct.new(
      :id,
      keyword_init: true
    ) { include Seahorse::Structure }

    GetHighScoreOutput = Struct.new(
      :high_score,
      keyword_init: true
    ) { include Seahorse::Structure }

    ListHighScoresInput = Struct.new(
      nil,
      keyword_init: true
    ) { include Seahorse::Structure }

    ListHighScoresOutput = Struct.new(
      :high_scores,
      keyword_init: true
    ) { include Seahorse::Structure }

    UpdateHighScoreInput = Struct.new(
      :id,
      :high_score,
      keyword_init: true
    ) { include Seahorse::Structure }

    UpdateHighScoreOutput = Struct.new(
      :high_score,
      keyword_init: true
    ) { include Seahorse::Structure }

  end
end
