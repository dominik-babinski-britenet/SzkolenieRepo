public virtual class TriggerHandler {
    public static void handle(TriggerHandler handler) {
        if (!handler.isEnabled()) {
            return;
        }

        switch on Trigger.operationType {
            when BEFORE_INSERT {
                handler.beforeInsert();
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate();
            }
            when BEFORE_DELETE {
                handler.beforeDelete();
            }
            when AFTER_INSERT {
                handler.afterInsert();
            }
            when AFTER_UPDATE {
                handler.afterUpdate();
            }
            when AFTER_DELETE {
                handler.afterDelete();
            }
            when AFTER_UNDELETE {
                handler.afterUndelete();
            }
        }
    }

    protected virtual Boolean isEnabled() {
        return true;
    }

    protected virtual void beforeInsert() {
    }

    protected virtual void beforeUpdate() {
    }

    protected virtual void beforeDelete() {
    }

    protected virtual void afterInsert() {
    }

    protected virtual void afterUpdate() {
    }

    protected virtual void afterDelete() {
    }

    protected virtual void afterUndelete() {
    }
}