module Broadcastable
  extend ActiveSupport::Concern

  included do
    plural_name = self.model_name.plural

    # --- GESTIONE BROADCAST ---
    after_create_commit -> { broadcast_prepend_to plural_name }

    after_update_commit do
      if respond_to?(:discarded?) && saved_change_to_discarded_at?
        if discarded?
          # Archiviato -> Rimuovi
          broadcast_remove_to plural_name
        else
          # Ripristinato -> Aggiungi di nuovo
          broadcast_prepend_to plural_name
        end
      else
        # Aggiornamento normale -> Sostituisci
        broadcast_replace_to plural_name
      end
    end
  end
end
