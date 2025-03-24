<meta http-equiv="Refresh" content="10;url=heap">
<%
Runtime rt = Runtime.getRuntime();
%>
Total size: <%=rt.totalMemory() / 1024 / 1024%>MB
<br>free size: <%=rt.freeMemory() / 1024 / 1024%>MB
<br>Heap size: <%=(rt.totalMemory()-rt.freeMemory())  / 1024 / 1024%>MB

