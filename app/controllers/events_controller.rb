class EventsController < BaseController
  before_filter :authenticate
  before_filter :authorize_event, :only => [:edit, :update, :destroy]

  def index
    @events_by_date = {}
    range_to_show.each do |day|
      @events_by_date[day] = []
      Event.find_each do |event|
        @events_by_date[day] << event if event.occurs_on? day
      end
    end
    @events = Event.all
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
  end

  def new
    @event = Event.new
  end

  def edit
    @event = Event.find(params[:id])
    @method = :put
  end

  def create
    @event = Event.new
    @event.title = params[:event_title]
    @event.user = current_user
    if @event.save
      redirect_to events_path, :flash => { :success => "Event was succesfully created" }
    else
      render action: "new"
    end
  end

  def update
    @event = Event.find(params[:id])
    @event.title = params[:event_title]
    if @event.save
      redirect_to events_path, :flash => { :success => "Event was succesfully updated" }
    else
      render action: "edit"
    end
  end

  # def destroy
  #   @event = Event.find(params[:id])
  #   @event.destroy
  #   redirect_to events_url, :flash => { :success => "Event was succesfully deleted" }
  # end

  private

  def authorize_event
    if not current_user == Event.find(params[:id]).user
      redirect_to :root, :flash => { :error => "You do not have permissions to this action" }
    end
  end

  def range_to_show
    date = params[:date] ? Date.parse(params[:date]) : Date.today
    first = date.beginning_of_month.beginning_of_week(:monday)
    last = date.end_of_month.end_of_week(:monday)
    (first..last).to_a
  end
end
