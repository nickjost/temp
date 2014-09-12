class ReservedLockersController < ApplicationController
  # def new
  #   render plain: params[:reserved_locker].inspect
  # end

  def create
    params = reserved_locker_params

    # Locker reservations are segregated 1-1000 small, 1001-2000 regular, 2001-3000 large
    # start looking for gaps
    prev = -1 + start =  1 if (params[:size] == 'Small')
    prev = -1 + start = 1001 if (params[:size] == 'Regular')
    prev = -1 + start = 2001 if (params[:size] == 'Large')
    found = false
    lockers = ReservedLocker.where(size: params[:size]).order(:number)
    lockers.find_each { |locker|
      unless (((locker.number - 1) == prev) || (locker.number == start))
        found = true
        params[:number] = locker.number - 1
        break
      end
      prev = locker.number
    }

    # couldn't find a valid low number or gap
    unless found
      # it could be that no reservations were found if so just pick the lowest possible (which is next)
      if (lockers.any?)
        params[:number] = prev + 1
      else
        # Just starting
        params[:number] = start
      end
    end

    @reserved_locker = ReservedLocker.new(params)
    # Only save if we haven't run out of lockers (3000) and if we did save perform a redirection...this happens
    # because of the left evaluating first and the && short circuiting on failure
    if ((params[:number].nil? || (!(params[:number] > 3000))) &&  @reserved_locker.save)
      redirect_to @reserved_locker
    else
      redirect_to action: 'create'
    end
  end

  def show
    @reserved_locker = ReservedLocker.find(params[:id])
  end

  def index
    @reserved_lockers = ReservedLocker.all
  end

  def destroy
    # NOTE BENE: We delete by locker number and not by ID
    @reserved_locker = ReservedLocker.find(params[:id])
    @reserved_locker.delete
    redirect_to action: 'index'
  end

  private
  def reserved_locker_params
    params.require(:reserved_locker).permit(:id, :size, :number)
  end
end
