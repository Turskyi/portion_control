package com.turskyi.portion_control

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

/**
 * Implementation of App Widget functionality.
 */
class PortionControlWidget : HomeWidgetProvider() {
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

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    // Get reference to SharedPreferences.
    val widgetData: SharedPreferences = HomeWidgetPlugin.getData(context)

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

        val consumed: String? = widgetData.getString("text_consumed", null)

        setTextViewText(R.id.text_consumed, consumed ?: "")

        val weight: String? = widgetData.getString("text_weight", null)

        setTextViewText(
            R.id.text_weight,
            weight ?: "",
        )

        val portionControl: String? = widgetData.getString(
            "portion_control",
            null,
        )

        setTextViewText(
            R.id.text_portion_control,
            portionControl ?: "",
        )

        val recommendation: String? = widgetData.getString(
            "text_recommendation",
            null,
        )

        setTextViewText(
            R.id.text_recommendation,
            recommendation ?: "",
        )

        val lastUpdated: String? = widgetData.getString(
            "text_last_updated",
            null,
        )

        setTextViewText(
            R.id.text_last_updated,
            lastUpdated ?: "",
        )

        // Get image and put it in the widget if it exists.
        val imagePath: String? = widgetData.getString(
            "image",
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
        } else if (recommendation.isNullOrEmpty()) {
            // Default messages with emojis.
            val defaultMessages: List<String> = listOf(
                "🍽️ Oops! No meal data available.",
                "🤷 Looks like we couldn’t log your portion this time.",
                "🥗 No recommendation? Trust your instincts today!",
                "📊 Data’s taking a break - try again soon!",
                "🚀 Tracking paused, try again later!",
                "😴 No portions logged - rest day?",
                "❌ No entry available",
                "🤔 No portion info right now"
            )

            setTextViewText(
                R.id.text_recommendation,
                defaultMessages.random(),
            )
        }
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}