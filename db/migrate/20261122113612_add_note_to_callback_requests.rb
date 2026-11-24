class AddNoteToCallbackRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :callback_requests, :note, :text
  end
end
