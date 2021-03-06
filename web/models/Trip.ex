defmodule PlanIt.Trip do
  use Ecto.Schema
  alias PlanIt.EditPermission
  alias PlanIt.Repo
  
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "trip" do
    belongs_to :user, PlanIt.User

    field :name, :string
    field :publish, :boolean
    field :upvotes, :integer, default: 0
    field :downvotes, :integer, default: 0
    field :photo_url, :string
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime

    has_many :card, PlanIt.Card
    has_many :favorited_trip, PlanIt.Trip

    timestamps()
  end

  def insert_trip(params) do
    {message, changeset}  = Repo.insert(PlanIt.Trip.changeset(%PlanIt.Trip{}, params))
    message2 = PlanIt.Trip.add_edit_permission(changeset)
    case {message, message2} do
      {:ok, :ok} -> {:ok, changeset}
      {_, :ok} -> {message, changeset}
      {:ok, _} -> {message2, changeset}
      _ -> {message, changeset}
    end
  end

  def add_edit_permission(changeset) do
    params = %{
      "user_id": changeset.user_id,
      "trip_id": changeset.id
    }

    Repo.insert!(EditPermission.changeset(%EditPermission{}, params))
  end

  def changeset(trip, params) do
    trip
    |> cast(params, [:name, :publish, :upvotes, :downvotes, :photo_url, :start_time, :end_time, :user_id])
    |> validate_required([:name, :user_id])
  end
end
