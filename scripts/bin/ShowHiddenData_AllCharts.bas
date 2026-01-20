Sub ShowHiddenData_AllCharts()
    Dim ws As Worksheet
    Dim ch As ChartObject

    For Each ws In ActiveWorkbook.Worksheets
        For Each ch In ws.ChartObjects
            ch.Chart.DisplayBlanksAs = xlNotPlotted
            ch.Chart.PlotVisibleOnly = False
        Next ch
    Next ws
End Sub
