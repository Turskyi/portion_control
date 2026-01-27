package com.turskyi.portion_control

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import com.turskyi.portion_control.PortionControlWidget.Companion.KEY_IMAGE_PATH
import com.turskyi.portion_control.PortionControlWidget.Companion.KEY_PORTION_CONTROL
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File
import java.util.Locale

/**
 * Implementation of App Widget functionality.
 */
class PortionControlWidget : HomeWidgetProvider() {
    companion object {
        const val KEY_PORTION_CONTROL = "text_portion_control"
        const val KEY_IMAGE_PATH = "image"
        const val KEY_LOCALE = "text_locale"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId: Int in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

// Create a localized context for resource lookups based on the provided
// language code.
private fun getLocalizedContext(
    context: Context,
    languageCode: String
): Context {
    // Use forLanguageTag for standard BCP 47 tags (e.g., "en", "uk").
    val locale: Locale = Locale.forLanguageTag(languageCode)
    Locale.setDefault(locale)
    val config = Configuration(
        context.resources.configuration,
    )
    config.setLocale(locale)

    // `createConfigurationContext` is safe and will NOT crash the widget.
    // It is specifically designed to create a Context with overridden
    // resources.
    return context.createConfigurationContext(config)
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    // Get reference to SharedPreferences.
    val widgetData: SharedPreferences = HomeWidgetPlugin.getData(context)

    // Get the locale from widget data and create localized context.
    val languageCode: String = widgetData.getString(
        PortionControlWidget.KEY_LOCALE,
        "en",
    ) ?: "en"

    val localizedContext: Context = getLocalizedContext(
        context,
        languageCode,
    )

    val views: RemoteViews = RemoteViews(
        context.packageName,
        R.layout.portion_control_widget,
    ).apply {
        // Open App on Widget Click.
        val pendingIntent: PendingIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java
        )

        setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        val portionControl: String? = widgetData.getString(
            KEY_PORTION_CONTROL,
            null,
        )

// Default messages with emojis.
        val defaultMessages: List<String> = listOf(
            localizedContext.getString(
                R.string.oops_no_meal_data_available,
            ),
            localizedContext.getString(
                R.string.looks_like_we_couldn_t_log_your_portion_this_time,
            ),
            localizedContext.getString(
                R.string.no_recommendation_trust_your_instincts_today,
            ),
            localizedContext.getString(
                R.string.data_s_taking_a_break_try_again_soon,
            ),
            localizedContext.getString(
                R.string.tracking_paused_try_again_later,
            ),
            localizedContext.getString(
                R.string.no_portions_logged_rest_day,
            ),
            localizedContext.getString(R.string.no_entry_available),
            localizedContext.getString(
                R.string.no_portion_info_right_now,
            ),
        )

        setTextViewText(
            R.id.text_portion_control,
            if (!portionControl.isNullOrEmpty()) {
                localizedContext.getString(
                    R.string.portion_control_g,
                    portionControl,
                )
            } else {
                defaultMessages.random()
            }
        )

        // Get image and put it in the widget if it exists.
        val imagePath: String? = widgetData.getString(
            KEY_IMAGE_PATH,
            null,
        )

        if (!imagePath.isNullOrEmpty()) {
            val imageFile = File(imagePath)
            val imageExists: Boolean = imageFile.exists()

            if (imageExists) {
                val myBitmap: Bitmap? = BitmapFactory.decodeFile(
                    imageFile.absolutePath,
                )

                if (myBitmap != null) {
                    setImageViewBitmap(R.id.image, myBitmap)
                }
            }
        }
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}