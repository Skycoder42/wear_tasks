import io.sentry.android.core.SentryAndroid
import io.sentry.SentryOptions.BeforeSendCallback
import io.sentry.Hint
import android.app.Application

class WearTasksApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        SentryAndroid.init(this) { options ->
            options.dsn = "TODO"
        }
    }
}
