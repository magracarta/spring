<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 미결사항
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-29 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGrid;
	var pageType = "${inputParam.__page_type}";
	$(document).ready(function() {
		fnDateInit();
		// AUIGrid 생성
		createAUIGrid();
		goSearch();

		fnInit();
	});

	function fnDateInit() {
		var now = "${inputParam.s_current_dt}";
		$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
	}

	function fnInit() {
		if(pageType != "JOB_REPORT") {
			$("#_goTodoProcess").addClass("dpn");
		}
	}

	function fnSetFrontPage() {
		var data = AUIGrid.getGridData(auiGrid);

		try {
			opener.${inputParam.parent_js_name}(data);
		} catch(e) {
			alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
		}
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	// 미결사항등록
	function goNew() {
		var params = {
			"machine_seq" : $M.getValue("__s_machine_seq"),
			"as_no" : $M.getValue("as_no")
		};
		var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=300, left=0, top=0";
		$M.goNextPage('/serv/serv0101p08', $M.toGetParam(params), {popupStatus : popupOption});
	}

	// 정리처리
	function goTodoProcess() {
		var itemArr = AUIGrid.getCheckedRowItems(auiGrid);

		if(itemArr.length == 0) {
			alert("정비처리 할 항목을 먼저 선택해주세요.");
			return;
		}

		var data = new Array();
		for(var i=0; i<itemArr.length; i++) {
			var seq = itemArr[i].item.as_todo_seq;
			for(var j=0; j<2; j++) {
				var item = new Object();
				item.as_todo_seq = itemArr[i].item.as_todo_seq;
				item.assign_mem_no = itemArr[i].item.assign_mem_no;
				item.plan_dt = itemArr[i].item.plan_dt;
				if(j==0) {
					item.order_text = "이전미결 : " + itemArr[i].item.todo_text;
					item.job_report_order_seq = seq;
					item.up_job_report_order_seq = 0;
					item._$depth = 1;
				} else {
					item.order_text = itemArr[i].item.as_todo_type_name + " : 여기부터 정비할 내용을 입력하시오.";
					item.job_report_order_seq = seq + 1000;
					item.up_job_report_order_seq = seq;
					item._$depth = 2;
				}
				data.push(item);
			}
		}
		try {
			opener.${inputParam.parent_js_name}(data);
			window.close();
		} catch(e) {
			alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
		}
	}

	function goSearch() {
		$M.setValue("__s_machine_seq", ${inputParam.__s_machine_seq});
		var params = {
			"__s_machine_seq" : $M.getValue("__s_machine_seq"),
			"s_start_dt" : $M.getValue("s_start_dt"),
			"s_end_dt" : $M.getValue("s_end_dt")
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method : "GET"},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);

					if(pageType != "JOB_REPORT") {
						fnSetFrontPage();
					}
				};
			}
		);
	}
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			// 체크박스 출력 여부
			showRowCheckColumn : true,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : true
		};
		var columnLayout = [
			{ 
				headerText : "미결사항", 
				dataField : "todo_text",
				width : "40%",
				style : "aui-left aui-popup"
			},
			{
				headerText : "처리사항", 
				dataField : "proc_text",
				width : "40%",
				style : "aui-left"
			},
			{ 
				headerText : "예정일자", 
				dataField : "plan_dt",
				width : "10%",
				style : "aui-center",
				dataType : "date",
				formatString : "yyyy-mm-dd",
			},
			{ 
				headerText : "처리일시", 
				dataField : "proc_date",
				width : "10%",
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
				visible : false
			},
			{ 
				headerText : "업무구분",
				width : "10%",
				dataField : "as_todo_type_name",
				style : "aui-center",
			},
			{
				headerText : "업무구분코드",
				dataField : "as_todo_type_cd",
				visible : false
			},
			{
				headerText : "장비일련번호",
				dataField : "machien_seq",
				visible : false
			},
			{
				headerText : "AS미결번호",
				dataField : "as_todo_seq",
				visible : false
			},
			{
				headerText : "할당직원",
				dataField : "assign_mem_no",
				visible : false
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "todo_text" ) {
				var params = {
					"s_machine_seq" : event.item.machine_seq,
					"s_as_todo_seq" : event.item.as_todo_seq
				};
				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=300, left=0, top=0";
				$M.goNextPage('/serv/serv0101p17', $M.toGetParam(params), {popupStatus : popupOption});
			}
		});	
		
		$("#auiGrid").resize();
	}	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="s_start_dt" dateformat="yyyy-MM-dd" name="s_start_dt">
<input type="hidden" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" value="${inputParam.s_current_dt}">
<input type="hidden" id="as_no" name="as_no" value="${inputParam.__s_as_no}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">					
			<div>					
<!-- 조회결과 -->
				<div class="title-wrap">
					<h4>조회결과</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
<!-- /조회결과 -->
			</div>		
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
				</div>	
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>