module Gaman
  module Prompt
    # defines the different prompts that can be offered to the user.
    %w( username
        password
        ).each_with_index do |prompt,i|
      const_set(prompt.capitalize, i)
    end
  end
end