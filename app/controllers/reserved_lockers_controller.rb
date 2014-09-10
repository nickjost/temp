class ReservedLockersController < ApplicationController
  # def new
  #   render plain: params[:reserved_locker].inspect
  # end

  def create
    params = reserved_locker_params
    @reserved_locker = ReservedLocker.new(params)


    # Locker reservations are segregated 1-1000 small, 1001-2000 regular, 2001-3000 large
    prev = 0 if (params[:reserved_locker][:size] == 'Small')
    prev = 1000 if (params[:reserved_locker][:size] == 'Regular')
    prev = 2000 if (params[:reserved_locker][:size] == 'Large')
    found = false
    ReservedLocker.where(size: params[:reserved_locker][:size]).find_each { |locker|
      unless ((locker.number - 1) == prev)
        found = true
        params[:reserved_locker][:number] = locker.number - 1
        break
      end

    }

    @reserved_locker.save
    redirect_to @reserved_locker
  end

  def show
    @reserved_locker = ReservedLocker.find(params[:id])
  end

  def index
    @reserved_lockers = ReservedLocker.all
  end

  private
  def reserved_locker_params
    params.require(:reserved_locker).permit(:size, :number)
  end
end
