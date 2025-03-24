<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 장비판매현황-연간 > null > 연간장비판매현황상세(연간집계)
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-21 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
			fnSetInit();

		});

		function fnSetInit() {

			var orgGubun = $M.nvl("${inputParam.org_gubun}", "");		// 본사:01, 대리점:02
			var rentalYn = $M.nvl("${inputParam.rental_yn}", "");		// 렌탈포함여부


			$M.setValue("year_mon"		, "${inputParam.year_mon}");	// case 1 : 해당년월로 조회
			$M.setValue("year_mon_st"	, "${inputParam.year_mon_st}");	// case 2 : 시작년월 ~ 종료년월 범위 조회
			$M.setValue("year_mon_ed"	, "${inputParam.year_mon_ed}"); // case 2 : 시작년월 ~ 종료년월 범위 조회
			$M.setValue("maker_cd"		, "${inputParam.maker_cd}");	// 메이커
			$M.setValue("org_gubun"		, "${inputParam.org_gubun}");	// 메이커
			$M.setValue("machine_name"		, "${inputParam.machine_name}");	// 메이커
			$M.setValue("maker_weight_type", "${inputParam.maker_weight_type}");	// 규격

			console.log(rentalYn + " / " + orgGubun);

			if (rentalYn != "N") {
				if(rentalYn == 'Y') {
					// 렌탈여부 포함
					$("input:checkbox[id='sale_base']").prop("checked", true);
					$("input:checkbox[id='rental_base']").prop("checked", true);
	// 				$("input:checkbox[id='sale_agncy']").prop("checked", true);
	// 				$("input:checkbox[id='rental_agncy']").prop("checked", true);


	// 				if(orgGubun == '01') {
	// 					$("input:checkbox[id='sale_base']").prop("checked", true);
	// 					$("input:checkbox[id='rental_base']").prop("checked", true);
	// 				} else if(orgGubun == '02') {
	// 					$("input:checkbox[id='sale_agncy']").prop("checked", true);
	// 					$("input:checkbox[id='rental_agncy']").prop("checked", true);
	// 				}
				} else {
					// 렌탈여부 미포함
					$("input:checkbox[id='sale_base']").prop("checked", true);
	// 				$("input:checkbox[id='sale_agncy']").prop("checked", true);


	// 				if(orgGubun == '01') {
	// 					$("input:checkbox[id='sale_base']").prop("checked", true);
	// 				} else if(orgGubun == '02') {
	// 					$("input:checkbox[id='sale_agncy']").prop("checked", true);
	// 				}
				}
			}

			var searchMode =  $M.nvl("${inputParam.search_mode}", "");

			if(searchMode != "") {
				if(searchMode == '01') {
					$("input:checkbox[id='sale_base']").prop("checked", true);
// 					$("input:checkbox[id='sale_agncy']").prop("checked", true);
				} else if(searchMode == '03') {
// 					$("input:checkbox[id='sale_agncy']").prop("checked", true);
					$("input:checkbox[id='rental_base']").prop("checked", true);
				} else if(searchMode == '00') {
					$("input:checkbox[id='sale_base']").prop("checked", true);
// 					$("input:checkbox[id='sale_agncy']").prop("checked", true);
					$("input:checkbox[id='rental_base']").prop("checked", true);
// 					$("input:checkbox[id='rental_agncy']").prop("checked", true);
				}
			};

// 			if(searchMode != "") {
// 				if(searchMode == '01') {
// 					$("input:checkbox[id='sale_base']").prop("checked", true);
// 					$("input:checkbox[id='sale_agncy']").prop("checked", true);
// 				} else if(searchMode == '02') {
// 					// 본사렌탈
// 					$("input:checkbox[id='sale_base']").prop("checked", true);
// 					$("input:checkbox[id='rental_base']").prop("checked", true);
// 				} else if(searchMode == '03') {
// 					$("input:checkbox[id='sale_agncy']").prop("checked", true);
// 					$("input:checkbox[id='rental_agncy']").prop("checked", true);
// 				} else if(searchMode == '00') {
// 					$("input:checkbox[id='sale_base']").prop("checked", true);
// 					$("input:checkbox[id='sale_agncy']").prop("checked", true);
// 					$("input:checkbox[id='rental_base']").prop("checked", true);
// 					$("input:checkbox[id='rental_agncy']").prop("checked", true);
// 				}
// 			};

			goSearch();
		}


		function goSearch() {

			var checkedNum = $("input[type='checkbox']").filter(':checked').size();

			if($("input:checkbox[id='s_masking_yn']").is(":checked") === true) {
				checkedNum = checkedNum-1;
			};

			if(checkedNum < 1) {
				alert("판매유형구분은 최소 1개 이상 선택해야 합니다.");
				return;
			};

			var param = {
				year_mon  	 : $M.getValue("year_mon"),
				year_mon_st  : $M.getValue("year_mon_st"),
				year_mon_ed  : $M.getValue("year_mon_ed"),
				machine_name : $M.getValue("machine_name"),
				maker_cd 	 : $M.getValue("maker_cd"),
				org_gubun 	 : $M.getValue("org_gubun"),
				sale_base 	 : $M.getValue("sale_base"),
// 				sale_agncy 	 : $M.getValue("sale_agncy"),
				rental_base  : $M.getValue("rental_base"),
// 				rental_agncy : $M.getValue("rental_agncy"),
				maker_weight_type : $M.getValue("maker_weight_type"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					};
				}
			);
		}

		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "mem_no",
				showRowNumColumn: true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    dataField: "org_gubun",
				    visible: false,
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText: "본/대리점",
				    headerText: "본/위탁판매점",
				    dataField: "org_gubun_name",
					width : "110",
					minWidth : "10",
					style : "aui-center"
				},
				{
					headerText : "관리번호",
					dataField : "machine_doc_no",
					width : "70",
					minWidth : "25",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
	                  var ret = "";
	                  if (value != null && value != "" && value != '수출') {
	                     ret = value.split("-");
	                     ret = ret[0]+"-"+ret[1];
	                     ret = ret.substr(4, ret.length);
	                  } else {
	                	  ret = value;
	                  }
	                   return ret;
	               },
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value != null && value != "" && value != '수출') {
							return "aui-popup"
						};
					},
				},
				{
				    headerText: "차대번호",
				    dataField: "body_no",
					width : "145",
					minWidth : "25",
					style : "aui-center"
				},
				{
				    headerText: "모델명",
				    dataField: "machine_name",
					width : "130",
					minWidth : "25",
					style : "aui-left",
				},
				{
				    headerText: "담당자",
				    dataField: "doc_mem_name",
					width : "75",
					minWidth : "25",
					style : "aui-center"
				},
				{
					headerText : "작성일",
					dataField : "doc_dt",
					width : "65",
					minWidth : "25",
					dataType : "date",
					formatString : "yy-mm-dd",
					style : "aui-center"
				},
				{
				    headerText: "고객명",
				    dataField: "cust_name",
					width : "95",
					minWidth : "25",
					style : "aui-center",
				},
				{
					headerText: "휴대폰",
					dataField: "hp_no",
					width : "110",
					minWidth : "25",
					style : "aui-center"
				},
				{
					headerText: "출고일",
					dataField: "out_dt",
					width : "65",
					minWidth : "25",
					dataType : "date",
					formatString : "yy-mm-dd",
					style : "aui-center"
				},
				{
					headerText: "판매유형",
					dataField: "sale_type_sr_name",
					width : "70",
					minWidth : "25",
					style : "aui-center"
				},
				{
					headerText: "도착지",
					dataField: "arrival_area_name",
					width : "215",
					minWidth : "25",
					style : "aui-left"
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var param = {
					machine_doc_no : event.item.machine_doc_no
				};

				if(event.dataField == 'machine_doc_no') {
					if (event.item.machine_doc_no != '수출') {
						var popupOption = "";
						$M.goNextPage('/sale/sale0101p03', $M.toGetParam(param), {popupStatus : popupOption});
					}
				};
			});
		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '연간장비판매현황상세');
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="year_mon" 			id="year_mon" 			value="">
	<input type="hidden" name="year_mon_st" 		id="year_mon_st" 		value="">
	<input type="hidden" name="year_mon_ed" 		id="year_mon_ed" 		value="">
	<input type="hidden" name="machine_name" 		id="machine_name" 		value="">
	<input type="hidden" name="maker_cd" 			id="maker_cd" 			value="">
	<input type="hidden" name="org_gubun" 			id="org_gubun" 			value="">
	<input type="hidden" name="maker_weight_type" 	id="maker_weight_type"	value="">

<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="title-wrap">
				<c:set var="yearMon" value="${inputParam.year_mon}"/>
				<c:choose>
					<c:when test="${fn:length(yearMon) eq 4}">
						<h4>${fn:substring(yearMon, 0, 4)}-${fn:substring(yearMon, 4, 6)}월 조회결과</h4>
					</c:when>
					<c:when test="${fn:length(yearMon) eq 6}">
						<h4>${fn:substring(yearMon, 0, 4)}년 조회결과</h4>
					</c:when>
				</c:choose>

				<div class="condition-items">
					<div class="condition-item">
						<div>
							<strong class="pr15">판매유형구분</strong>
						</div>
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="checkbox" id="sale_base" name="sale_base" value="Y">
							<label class="form-check-label" for="sale_base">순수판매</label>
						</div>
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="checkbox" id="rental_base" name="rental_base" value="Y">
							<label class="form-check-label" for="rental_base">본사렌탈</label>
						</div>
<!-- 						<div class="form-check form-check-inline"> -->
<!-- 							<input class="form-check-input" type="checkbox" id="sale_base" name="sale_base" value="Y"> -->
<!-- 							<label class="form-check-label" for="sale_base">본사판매</label> -->
<!-- 						</div> -->
<!-- 						<div class="form-check form-check-inline"> -->
<!-- 							<input class="form-check-input" type="checkbox" id="sale_agncy" name="sale_agncy" value="Y"> -->
<!-- 							<label class="form-check-label" for="sale_agncy">대리점판매</label> -->
<!-- 						</div> -->
<!-- 						<div class="form-check form-check-inline"> -->
<!-- 							<input class="form-check-input" type="checkbox" id="rental_base" name="rental_base" value="Y"> -->
<!-- 							<label class="form-check-label" for="rental_base">본사렌탈</label> -->
<!-- 						</div> -->
<!-- 						<div class="form-check form-check-inline"> -->
<!-- 							<input class="form-check-input" type="checkbox" id="rental_agncy" name="rental_agncy" value="Y"> -->
<!-- 							<label class="form-check-label" for="rental_agncy">대리점렌탈</label> -->
<!-- 						</div> -->
					</div>
					<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
					<div class="form-check form-check-inline">
						<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
						<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
					</div>
					</c:if>
					<div class="form-check form-check-inline">
						<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
					</div>
					<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
				</div>
			</div>
			<div style="margin-top: 5px; height: 470px; " id="auiGrid"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<button type="button" class="btn btn-info" style="width: 50px;" onclick="javascript:window.close();">닫기</button>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- /상단 폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->

</form>
</body>
</html>
