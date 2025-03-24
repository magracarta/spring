<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > KPI집계 > null > 부품 비교군
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">
<%-- 여기에 스크립트 넣어주세요. --%>

	var monArr = ["12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11"];
	var monthArr = [];
	var dataList = [];
	var partGroupCd = JSON.parse('${codeMapJsonObj['PART_GROUP']}');
	
	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();
	});

	function fnClose() {
		window.close();
	}
	
	//그리드 스타일을 동적으로 바꾸기
 	function myCellStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
          if (item.col == "매출" && value != "매출") {
            	return "aui-popup";
          } else if (item.col == "매출" && value == "매출") {
        	  	return "aui-sale-graph";
          }
    };
	
	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			showRowNumColumn : false,
			rowIdField : "_$uid",
            // 그룹핑 후 셀 병합 실행
            enableCellMerge : true,
            enableSorting  : false,
            wordWrap : true
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
			    headerText: "부품",
			    dataField: "part_no",
				width : "90",
				minWidth : "90",
				cellMerge : true,
				colSpan : 3,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					if ("${inputParam.s_type}" == "G") {
						var retStr = value;
						for(var j = 0; j < partGroupCd.length; j++) {
							if(partGroupCd[j]["code_value"] == value) {
								retStr ="("+value+") "+partGroupCd[j]["code_name"];
								break;
							}
						}
						return retStr;
					} else {
						return value;
					}
				},
			},
			{
			    dataField: "col",
				width : "95",
				minWidth : "95",
				cellMerge : true,
				styleFunction: myCellStyleFunction,
			},
			{
				dataField : "year",
				width : "95",
				minWidth : "95"
			}
		];
		
		for (var i = 0; i < 12; ++i) {
			var mon = "month_"+$M.lpad(i+1, 2, '0');
			columnLayout.push(
					{
						dataField : mon,
						headerText : $M.toNum(monArr[i])+"월",
						style : "aui-right",
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
		var list = ${list};
		list.sort($M.sortMulti("partIndex", "colIndex", "-year"));
		
		AUIGrid.setGridData(auiGrid, list);
		
		AUIGrid.setFooter(auiGrid, footerColumnLayout);
		$("#auiGrid").resize();
		// 클릭 시 팝업페이지 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(monthArr.indexOf(event.dataField) > -1 && event.item.col == "매출") {
					var headerText = AUIGrid.getColumnItemByDataField(auiGrid, event.dataField).headerText;
					var year = event.item.year;
					if (headerText == "12월") {
						year = $M.toNum(year) -1;
					}
					var mon = $M.lpad($M.toNum(headerText), 2, 0);
					var lastDay = new Date(year, $M.toNum(mon), 0).getDate();
					var param = {
						s_start_dt : year+mon+"01",
						s_end_dt : year+mon+lastDay,
						part_production_oke : "계",
						maker_stat_name : event.item.part_no
					}
					
					var type = "${inputParam.s_type}";
 					param["s_type"] = type;
 					if (type == "P") { // 부품 조회
 						param["s_kpi_part_no_str"] = event.item.part_no; // s_part_no로 할 경우 상세 팝업에서 오류남.. (s_part_no가 이미 있음!)
 						if (event.item.part_no == "Total") {
 							param["s_kpi_part_no_str"] = "${inputParam.s_part_no_str}"; // 전체일 경우
 						} else {
 							param["s_kpi_part_no_str"] = event.item.part_no;
 						}
 					
 					} else if (type == "G") { // 부품그룹 조회
 						if (event.item.part_no == "Total") {
 							param["s_part_group_cd_str"] = "${inputParam.s_part_group_cd_str}";
 						} else {
 							var retStr = event.item.part_no;
 							for(var j = 0; j < partGroupCd.length; j++) {
 								if(partGroupCd[j]["code_value"] == event.item.part_no) {
 									retStr ="("+event.item.part_no+") "+partGroupCd[j]["code_name"];
 									break;
 								}
 							}
 							param["maker_stat_name"] = retStr;
 							param["s_part_group_cd_str"] = event.item.part_no;
 						}
 					}
					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=700, left=0, top=0";
					$M.goNextPage("/part/part0601p01", $M.toGetParam(param), {popupStatus : popupOption});
				} else if (event.item.col == "매출" && event.value == "매출") {
					var param = {
						s_year : $M.toNum("${inputParam.s_year}")+3,
						s_part_no_str 	: "${inputParam.s_part_no_str}",
						s_name : event.item.part_no,
						s_name_view : event.item.part_no,
						s_type : "부품",
					}
					var list = AUIGrid.getGridData(auiGrid);
					var tempList = [];
					for (var i = 0; i < list.length; ++i) {
						if (list[i].part_no == event.item.part_no && list[i].col == "매출") {
							var data = [];
							for (var j = 0; j < 12; ++j) {
								data.push(list[i]["month_"+$M.lpad(j+1, 2, '0')]);
							}
							tempList.push({
								year : list[i].year,
								data : data
							});
						}
					}
					dataList = tempList;
					console.log(param);
					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=500, left=0, top=0";
					$M.goNextPage("/part/part0607p03", $M.toGetParam(param), {popupStatus : popupOption});
				}
		});
	}
	
	//엑셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "KPI집계-부품", "");
	}
	
</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
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
				<div class="title-wrap">
					<div class="left">
						<h4>비교군</h4>
					</div>
					<div class="right">						
						<button type="button" class="btn btn-default mr5" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
					</div>
				</div>						
				<div style="margin-top: 5px; height: 550px;" id="auiGrid"></div>
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