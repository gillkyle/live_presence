defmodule LivePresenceWeb.Visitors do
  def random_name do
    prefix = ~w(
      Adorable
      Adventurous
      Aggressive
      Alert
      Attractive
      Average
      Beautiful
      Blue-eyed
      Blushing
      Bright
      Clean
      Clear
      Cloudy
      Colorful
      Crowded
      Cute
      Dark
      Drab
      Distinct
      Dull
      Elegant
      Excited
      Fancy
      Filthy
      Glamorous
      Gleaming
      Gorgeous
      Graceful
      Grotesque
      Handsome
      Homely
      Light
      Long
      Magnificent
      Misty
      Motionless
      Muddy
      Old-fashioned
      Plain
      Poised
      Precious
      Prickly
      Proper
      Shiny
      Smoggy
      Sparkling
      Spotless
      Stormy
      Strange
      Ugly
      Ugly
      Unsightly
      Unusual
      Wide-eyed
      Zealous
    ) |> Enum.random()

    animal =
      ~w(
      Aardvark
      Albatross
      Alligator
      Alpaca
      Ant
      Anteater
      Antelope
      Ape
      Armadillo
      Baboon
      Badger
      Barracuda
      Bat
      Bear
      Beaver
      Bee
      Bison
      Boar
      Buffalo
      Butterfly
      Camel
      Caribou
      Cat
      Caterpillar
      Cattle
      Cheetah
      Chicken
      Chimpanzee
      Chinchilla
      Clam
      Cobra
    )
      |> Enum.random()

    "#{prefix} #{animal}"
  end

  # now we need a function for a set of random tailwind colors, we need the bg, which should be bg-<color>-100/50 but in the form of hex that we can easily interpolate, color which should be text-<color>-600, and finally the cursor color which should be text-<color>-500
  # this should use the input visitor_name to hash and get a random color
  def random_color(visitor_name) do
    colors = ~w(
      red
      yellow
      green
      blue
      indigo
      purple
      pink
    )

    # Hash the visitor_name and convert the result into an integer
    index =
      :crypto.hash(:sha256, visitor_name)
      |> :binary.bin_to_list()
      |> Enum.reduce(0, fn byte, acc -> rem(acc + byte, length(colors)) end)

    # Select color deterministically based on hashed index
    color = Enum.at(colors, index)

    # return hex values of the tailwind colors based on the color found
    case color do
      "red" ->
        %{
          bg: "#FEE2E250",
          text: "#C53030",
          cursor: "#9B2C2C",
          border: "#FED7D7"
        }

      "yellow" ->
        %{
          bg: "#FEF3C750",
          text: "#B7791F",
          cursor: "#975A16",
          border: "#FCD34D"
        }

      "green" ->
        %{
          bg: "#D1FAE550",
          text: "#2F855A",
          cursor: "#22543D",
          border: "#A7F3D0"
        }

      "blue" ->
        %{
          bg: "#DBEAFE50",
          text: "#2563EB",
          cursor: "#1E40AF",
          border: "#BFDBFE"
        }

      "indigo" ->
        %{
          bg: "#E0E7FF50",
          text: "#4C51BF",
          cursor: "#4338CA",
          border: "#C3DAFE"
        }

      "purple" ->
        %{
          bg: "#EBD4FF50",
          text: "#9333EA",
          cursor: "#7E22CE",
          border: "#D6BCFA"
        }

      "pink" ->
        %{
          bg: "#FED7E250",
          text: "#B83280",
          cursor: "#97266D",
          border: "#FBB6CE"
        }
    end
  end
end
