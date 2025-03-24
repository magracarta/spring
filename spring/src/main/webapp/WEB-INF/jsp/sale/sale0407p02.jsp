<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > MBO > MBO등록 > null
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-03-15 10:15:49
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;

		$(document).ready(function() {
			createAUIGrid();
			if("${inputParam.center_yn}" != "Y"){
				goSearchCenter();
			} else {
				$("#s_center_org_code").prop("disabled", true); // 센터 disabled
				$("#s_maker_cd").prop("disabled", true); // 메이커 disabled
			}
			goSearchSaleMboSeqNo();
		});


		// 조회년도의 MBO 차수 조회
		function goSearchSaleMboSeqNo() {
			var year = $M.getValue("s_search_year");
			$("select#s_seq_no option").remove();
			$('#s_seq_no').append('<option value="" >'+ "선택" +'</option>');

			// 선택한 년도의 차수 조회
			$M.goNextPageAjax("/sale/sale0407p01/searchMboSeqNo" + "/" + year, "", {method: "get"},
					function (result) {
						if (result.success) {
							for (i = 0; i < result.list.length; i++) {
								var optVal = result.list[i].seq_no;
								var optText = result.list[i].seq_no + "차";
								$('#s_seq_no').append('<option value="' + optVal + '">' + optText + '</option>');
							}
						}
					}
			);
		}
		
		function goSearch() {
			if($M.getValue("s_center_org_code") == ""){
				alert("센터를 선택해 주세요")
				return false;
			}
			if($M.getValue("s_sale_mbo_type_cd") == ""){
				alert("작성구분을 선택해 주세요")
				return false;
			}
			if($M.getValue("s_seq_no") == ""){
				alert("조회할 차수를 선택해주세요.");
				return false;
			}
			var param = {
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_sale_mem_no" : $M.getValue("s_sale_mem_no"),
				"s_center_org_code" : $M.getValue("s_center_org_code"),
				"s_search_year" : $M.getValue("s_search_year"),
				"s_seq_no" : $M.getValue("s_seq_no"),
				"s_sale_mbo_type_cd" : $M.getValue("s_sale_mbo_type_cd"),
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "get"},
				function (result) {
					if (result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						fnGridDataSet();
					} else {
						AUIGrid.clearGridData(auiGrid);
					}
				}
			);
		}

		// 합계 계산
		function fnGridDataSet() {
			var gridData = AUIGrid.getGridData(auiGrid);
			var makerArr = [];
			var columnArr = ["forecast_max", "forecast_avr", "forecast_min", "sale_expect_max", "sale_expect_avr", "sale_expect_min",];
			var sumObj = {}; // 컬럼 별 합계 저장
			var sumSObj = {}; // 얀마 미니 컬럼 별 합계 저장
			var sumLObj = {}; // 얀마 대형 컬럼 별 합계 저장

			// 메이커 목록
			for(var i = 0; i < gridData.length; i++){
				if(makerArr.includes(gridData[i].maker_name) == false && gridData[i].maker_name != ""){
					makerArr.push(gridData[i].maker_name);
				}
			}
			// 합계 산출
			for(var i=0; i<columnArr.length; i++){
				sumObj[columnArr[i]] = 0;
				sumSObj[columnArr[i]] = 0;
				sumLObj[columnArr[i]] = 0;
				for(var l=0; l < makerArr.length; l++){ // 메이커 별
					var subTyperArr = [];
					for(var j=0; j < gridData.length; j++){
						if(gridData[j].maker_name == makerArr[l] && gridData[j][columnArr[i]] != ""){
							if(subTyperArr.includes(gridData[j].machine_sub_type_cd) == false){ // 셀 병합되어있으면 한번만 더하기 위함
								subTyperArr.push(gridData[j].machine_sub_type_cd);
								sumObj[columnArr[i]] += $M.toNum(gridData[j][columnArr[i]]);
								if(gridData[j].maker_cd == "27" && gridData[j].machine_sub_type_cd <= "0104" || gridData[j].machine_sub_type_cd == "0111" || gridData[j].machine_sub_type_cd == "0109"){
									sumSObj[columnArr[i]] += $M.toNum(gridData[j][columnArr[i]]);
								} else{
									sumLObj[columnArr[i]] += $M.toNum(gridData[j][columnArr[i]]);
								}
							}
						}
					}
					for(var k=0; k < gridData.length; k++){
						if(gridData[k].machine_name == makerArr[l] + " 합계"){
							var item = {};
							item[columnArr[i]] = sumObj[columnArr[i]];
							AUIGrid.updateRow(auiGrid, item, k, false)
							sumObj[columnArr[i]] = 0;
						} else if(makerArr[l] == "얀마" && gridData[k].machine_name == "미니 합계"){
							var item = {};
							item[columnArr[i]] = sumSObj[columnArr[i]];
							AUIGrid.updateRow(auiGrid, item, k, false)
							sumSObj[columnArr[i]] = 0;
						} else if(makerArr[l] == "얀마" && gridData[k].machine_name == "대형 합계"){
							var item = {};
							item[columnArr[i]] = sumLObj[columnArr[i]];
							AUIGrid.updateRow(auiGrid, item, k, false)
							sumLObj[columnArr[i]] = 0;
						}
					}
				}
			}


		}




		// 닫기
		function fnClose() {
			window.close();
		}

		function goSearchCenter() {
			var saleMemNo = "${inputParam.s_sale_mem_no}";
			$("select#s_center_org_code option").remove();
			$('#s_center_org_code').append('<option value="" >'+ "- 선택 -" +'</option>');

			// 선택한 영업담당자의 담당센터 조회
			$M.goNextPageAjax(this_page + "/searchCenter" + "/" + saleMemNo, "", {method: "get"},
				function (result) {
					if (result.success) {
						for (i = 0; i < result.list.length; i++) {
							var optVal = result.list[i].center_org_code;
							var optText = result.list[i].center_org_name;
							$('#s_center_org_code').append('<option value="' + optVal + '">' + optText + '</option>');
						}
					}
				}
			);
		}


		// 그리드 생성
		function createAUIGrid() {

			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				// showEditedCellMarker : false,
				// rowBackgroundStyles : [], // 세로 셀 병합 후 그리드 깨질때 해결방법
				// 트리 펼치기
				displayTreeOpen : true,
				treeColumnIndex : 0,
				rowCheckDependingTree : true,
				// 셀 병합 실행
				enableCellMerge : true,
				cellMergeRowSpan:  true,
                cellMergePolicy: "withNull", // null 도 하나의 값으로 간주하여 다수의 null 을 병합된 하나의 공백으로 출력
				enableMovingColumn : false,
				rowStyleFunction : function(rowIndex, item) {
					if(item.machine_name.indexOf("합계") != -1) {
						return "aui-grid-row-depth3-style";
					}
					return "";
				},
			};

			var columnLayout = [
				{
					headerText : "모델명",
					dataField : "machine_name",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "규격",
					dataField : "machine_sub_type_name",
					width : "80",
					style : "aui-center",
					editable : false,
					cellMerge : true,
				},
				{
					dataField : "machine_sub_type_cd",
					visible : false,
				},
				{
					dataField : "maker_cd",
					visible : false,
				},
				{
					dataField : "maker_name",
					visible : false,
				},
				{
					dataField : "machine_plant_seq",
					visible : false,
				},
				{
					headerText : "수요예상",
					children : [
						{
							headerText : "MAX",
							dataField : "forecast_max",
							width : "50",
							style : "aui-center ",
							cellMerge: true, 
							mergeRef: "machine_sub_type_name", 
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
						},
						{
							headerText : "AVR",
							dataField : "forecast_avr",
							width : "50",
							style : "aui-center ",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
						},
						{
							headerText : "MIN",
							dataField : "forecast_min",
							width : "50",
							style : "aui-center ",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
							},
						},
					]

				},
				{
					headerText : "판매예상",
					dataField : "sale_forecast",
					children : [
						{
							headerText : "MAX",
							dataField : "sale_expect_max",
							width : "50",
							style : "aui-center ",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
							},
						},
						{
							headerText : "AVR",
							dataField : "sale_expect_avr",
							width : "50",
							editable : false,
							style : "aui-center ",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
						},
						{
							headerText : "MIN",
							dataField : "sale_expect_min",
							width : "50",
							style : "aui-center ",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
						},
					]
				},
				{
					headerText : "MS",
					dataField : "ms",
					children : [
						{
							headerText : "MAX",
							dataField : "ms_max",
							width : "50",
							editable : false,
							style : "aui-center ",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								// 판매예상 / 수요예상 %
								if(item.sale_expect_max > 0 && item.forecast_max > 0){
									var rate = Math.round(item.sale_expect_max / item.forecast_max * 100);
									if(isFinite(rate)){
										return rate;
									}
								}
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value + "%";
							},
						},
						{
							headerText : "AVR",
							dataField : "ms_avr",
							width : "50",
							editable : false,
							style : "aui-center ",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								// 판매예상 / 수요예상 %
								if(item.sale_expect_avr > 0 && item.forecast_avr > 0){
									var rate = Math.round(item.sale_expect_avr / item.forecast_avr * 100);
									if(isFinite(rate)){
										return rate;
									}
								}
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value + "%";
							},
						},
						{
							headerText : "MIN",
							dataField : "ms_min",
							width : "50",
							editable : false,
							style : "aui-center ",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								// 판매예상 / 수요예상 %
								if(item.sale_expect_min > 0 && item.forecast_min > 0){
									var rate = Math.round(item.sale_expect_min / item.forecast_min * 100);
									return rate;
								}
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value + "%";
							},
						},
					]
				},

			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();


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
		<!-- 컨텐츠 영역 -->
        <div class="content-wrap">
			<div class="search-wrap mt10">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="70px">
						<col width="50px">
						<col width="90px">
						<col width="40px">
						<col width="90px">
						<col width="60px">
						<col width="90px">
						<col width="40px">
						<col width="50px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>조회년도</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-12">
									<select class="form-control" id="s_search_year" name="s_search_year"  onchange="javascript:goSearchSaleMboSeqNo();">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<option value="${i}" <c:if test="${i == inputParam.s_current_year}">selected</c:if>>${i}년</option>
										</c:forEach>
									</select>
								</div>
							</div>
						</td>
						<th>메이커</th>	
						<td>
							<div class="form-row inline-pd">
								<div class="col-12">
									<select class="form-control" id="s_maker_cd" name="s_maker_cd">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<c:if test="${item.code_v1 eq 'Y' }">
<%--												<option value="${item.code_value}" >${item.code_name}</option>--%>
												<option value="${item.code_value}" ${inputParam.center_yn eq "Y" and item.code_value == "27" ? 'selected' : 'item.code_value' }>${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</div>
							</div>
						</td>
						<th>센터</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-12">
									<select class="form-control" id="s_center_org_code" name="s_center_org_code">
										<option value="">- 선택 -</option>
										<c:forEach var="list" items="${codeMap['WAREHOUSE']}">
											<c:if test="${list.code_value ne '6000'}">
												<option value="${list.code_value}">${list.code_name}</option>
												<c:if test="${inputParam.center_yn eq 'Y'}"><option value="${list.code_value}" ${list.code_value == (SecureUser.warehouse_cd ne '' ? SecureUser.warehouse_cd : SecureUser.org_code) ? 'selected' : 'item.code_value' }>${list.code_name}</c:if></option>
											</c:if>
										</c:forEach>
									</select>
								</div>
							</div>
						</td>
						<th>작성구분</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-12">
									<select class="form-control" id="s_sale_mbo_type_cd" name="s_sale_mbo_type_cd">
										<option value="">- 선택 -</option>
										<option value="C">센터인원</option>
										<option value="S">마케팅담당자</option>
									</select>
								</div>
							</div>
						</td>
						<th>차수</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-12">
									<select class="form-control" id="s_seq_no" name="s_seq_no">
										<option value="">선택</option>
									</select>
								</div>
							</div>
						</td>
						<td>
							<div class="col-12">
								<button type="button" class="btn btn-important ml5" style="width: 50px;" onclick="goSearch()">조회</button>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<div class="title-wrap">
				<h4>조회결과</h4>
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<!-- 그리드 영역 -->
			<div id="auiGrid" style="margin-top: 5px; height: 650px;"></div>
			<!-- 우측 하단 버튼 영역 -->
			<div class="btn-group mt5">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
	<!-- /팝업 -->
</form>
</body>
</html>