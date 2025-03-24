<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > KPI집계 > null > 외자부품확인
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-12 10:31:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">
<%-- 여기에 스크립트 넣어주세요. --%>

	var monArr = ["12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11"];
	var monthArr = [];
	var makerJosnTemp = [];
	var makerJosn = [];
	var dataList = [];
	var auiGrid;
	var auiGridRight;
	var auiGridHide;

	$(document).ready(function() {
		
		makerJsonTemp = JSON.parse('${codeMapJsonObj['MAKER']}');
		var initArr = [];
		for (var i = 0; i < makerJsonTemp.length; ++i) {
			if (makerJsonTemp[i].use_yn == "Y") {
				makerJosn.push(makerJsonTemp[i]);
				initArr.push(makerJsonTemp[i].code_value);
			}
		}
		
		// 그리드 생성
		createAUIGrid();
		createAUIGridRight();
		
		fnSyncAUIGridScroll(auiGrid,auiGridRight,"Y","Y");		//그리드 동기화
	});

	function fnClose() {
		window.close();
	}
	
	//그리드 스타일을 동적으로 바꾸기
 	function myCellStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
          if (item.col2 == "매출(KRW)" && item.col != "Cumulative Sale") {
            	return "aui-popup";
          }
    };
	
	// 왼쪽 그리드생성
	function createAUIGrid() {
		var gridPros = {
			showRowNumColumn : false,
			rowIdField : "_$uid",
            // 그룹핑 후 셀 병합 실행
            enableCellMerge : true,
            enableSorting  : false
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
			    headerText: "구분",
			    dataField: "maker_name",
				width : "55",
				minWidth : "50",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					var ret = value;
					for (var i = 0; i <makerJosn.length; ++i) {
						if (makerJosn[i].code_value == value) {
							ret = makerJosn[i].code_name;
						}
					}
					return ret;
				},
				cellMerge : true,
				colSpan : 3
			},
			{
			    dataField: "col",
				width : "95",
				minWidth : "95",
				style : "aui-center",
				cellMerge : true,
				wrapText : true,
			},
			{
			    dataField: "col2",
				width : "95",
				minWidth : "95"
			},
		];
		
		for (var i = 0; i < 12; ++i) {
			var mon = "month_"+$M.lpad(i+1, 2, '0');
			columnLayout.push(
					{
						dataField : mon,
						headerText : (i == 0 ? "${leftYear-1}" : "${leftYear}") +"-"+monArr[i],
						style : "aui-right",
						width : "75",
						minWidth : "75",
						styleFunction: myCellStyleFunction,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							return value == null || value == "0" ? "" : $M.setComma(value)
						},
					}
			);
			monthArr.push(mon);
		}
		
		// 푸터레이아웃
		var footerColumnLayout = [];

		// 그리드 출력
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		var list = ${leftList};
		list.sort($M.sortMulti("maker_cd", "colIndex"));
		
		AUIGrid.setGridData(auiGrid, list);
		
		AUIGrid.setFooter(auiGrid, footerColumnLayout);
		$("#auiGrid").resize();
		// 클릭 시 팝업페이지 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(monthArr.indexOf(event.dataField) > -1 && event.item.col2 == "매출(KRW)" && event.item.col != "Cumulative Sale") {
					var headerText = AUIGrid.getColumnItemByDataField(auiGrid, event.dataField).headerText;
					var year = "${leftYear}";
					if (event.dataField == "month_01") {
						year = $M.toNum(year) -1;
					}
					var mon = headerText.split("-")[1];
					var lastDay = new Date(year, $M.toNum(mon), 0).getDate();
					var param = {
						s_start_dt : year+mon+"01",
						s_end_dt : year+mon+lastDay,
					}
					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=700, left=0, top=0";
					$M.goNextPage("/part/part0607p05", $M.toGetParam(param), {popupStatus : popupOption});
				} 
		});
		
		for (var i = 0; i < 12; ++i) {
			var mon = "hide_month_"+$M.lpad(i+1, 2, '0');
			columnLayout.push(
					{
						dataField : mon,
						headerText : (i == 0 ? "${rightYear-1}" : "${rightYear}") +"-"+monArr[i],
						style : "aui-right",
						width : "75",
						minWidth : "75",
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							return value == null || value == "0" ? "" : $M.setComma(value)
						},
					}
			);
			monthArr.push(mon);
		}
		
		// 엑셀다운로드용 안보이는 그리드
		auiGridHide = AUIGrid.create("#auiGridHide", columnLayout, gridPros);
		
		var hideList = ${rightList};
		hideList.sort($M.sortMulti("maker_cd", "colIndex"));
		console.log(hideList);
		console.log(list);
		for (var i = 0; i < list.length; ++i) {
			for (var j = 1; j <= 12; ++j) {
				list[i]["hide_month_"+$M.lpad(j, 2, "0")] = hideList[i]["month_"+$M.lpad(j, 2, "0")];
			}
		}
		AUIGrid.setGridData(auiGridHide, list);
	}
	
	// 그리드생성
	function createAUIGridRight() {
		var gridPros = {
			showRowNumColumn : false,
			rowIdField : "_$uid",
            // 그룹핑 후 셀 병합 실행
            enableSorting  : false
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [];
		
		for (var i = 0; i < 12; ++i) {
			var mon = "month_"+$M.lpad(i+1, 2, '0');
			columnLayout.push(
					{
						dataField : mon,
						headerText : (i == 0 ? "${rightYear-1}" : "${rightYear}") +"-"+monArr[i],
						style : "aui-right",
						width : "75",
						minWidth : "75",
						styleFunction: myCellStyleFunction,
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							return value == null || value == "0" ? "" : $M.setComma(value)
						},
					}
			);
			monthArr.push(mon);
		}
		
		// 푸터레이아웃
		var footerColumnLayout = [];

		// 그리드 출력
		auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
		// 그리드 갱신
		var list = ${rightList};
		list.sort($M.sortMulti("maker_cd", "colIndex"));
		
		AUIGrid.setGridData(auiGridRight, list);
		
		AUIGrid.setFooter(auiGridRight, footerColumnLayout);
		$("#auiGridRight").resize();
		// 클릭 시 팝업페이지 호출
			AUIGrid.bind(auiGridRight, "cellClick", function(event) {
				if(monthArr.indexOf(event.dataField) > -1 && event.item.col2 == "매출(KRW)") {
					var headerText = AUIGrid.getColumnItemByDataField(auiGridRight, event.dataField).headerText;
					var year = "${rightYear}";
					if (event.dataField == "month_01") {
						year = $M.toNum(year) -1;
					}
					var mon = headerText.split("-")[1];
					var lastDay = new Date(year, $M.toNum(mon), 0).getDate();
					var param = {
						s_start_dt : year+mon+"01",
						s_end_dt : year+mon+lastDay,
					}
					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=700, left=0, top=0";
					$M.goNextPage("/part/part0607p05", $M.toGetParam(param), {popupStatus : popupOption});
				} 
		});
	}
	
	//엑셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGridHide, "외자부품확인", "");
	}
	
</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div id="auiGridHide" style="display: none;"></div>
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<span style="display: inline-block; width: 60%"><h4>${leftYear}년</h4></span>
				<span style="display: inline-block;"><h4 style="margin-left: 5px;">${rightYear}년</h4></span>
				<span style="display: inline-block;position: relative;float: right;"><button type="button" class="btn btn-default mr5" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button></span>
				<div style="display: inline-block; width: 100%;">						
					<div style="margin-top: 5px; height: 550px; display: inline-block; width: 60%" id="auiGrid"></div>
					<div style="margin-top: 5px; height: 550px; display: inline-block; width: 39%" id="auiGridRight"></div>
				</div>
			</div>	
			<div class="btn-group mt10">
				<div class="left">
				</div>	
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnClose()">닫기</button>
				</div>
			</div>	
<!-- /폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>