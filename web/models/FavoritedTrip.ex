defmodule PlanIt.FavoritedTrip do
  alias PlanIt.FavoritedTrip
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "favorited_trip" do
    belongs_to :user, PlanIt.User
    belongs_to :trip, PlanIt.Trip

    field :last_visited, :utc_datetime
    field :trip_name, :string

    timestamps()
  end

  def insert_favorited_trip(params) do
    IO.inspect("insert_favorited_trip")

    {message, changeset}  = Repo.insert(PlanIt.FavoritedTrip.changeset(%PlanIt.FavoritedTrip{}, params))
    message2 = PlanIt.FavoritedTrip.upvote_trip(changeset)
    case {message, message2} do
      {:ok, :ok} -> {:ok, changeset}
      {_, :ok} -> {message, changeset}
      {:ok, _} -> {message2, changeset}
      _ -> {message, changeset}
    end
  end

  def upvote_trip(changeset) do
    IO.inspect("upvote_trip")
    
    trip = Repo.get(Trip, changeset.trip_id)
    num_upvotes = trip.upvotes + 1

    params = %{
      "upvotes": num_upvotes
    }

    changeset = FavoritedTrip.changeset(trip, params)

    Repo.update(changeset)
  end

  def changeset(favorited_trip, params) do
    favorited_trip |> cast(params, [:user_id, :trip_id, :last_visited, :trip_name])
  end
end
