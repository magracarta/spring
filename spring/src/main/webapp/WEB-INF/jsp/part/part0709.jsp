<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 장기/충당/폐기부품관리 > null > null
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-04-10 09:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		var marginList = JSON.parse('${codeMapJsonObj['PART_PRICE_MARGIN']}');
		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			createAUIGrid(); // 메인 그리드
			$("#s_temp_yn").prop("checked", true);
			goSearch();
			$("#s_temp_yn").prop("checked", false);

		});
		
		function fnChangeColumn(event) {
			var target = event.target || event.srcElement;
			if(!target)	return;

			var checked = target.checked;
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
		}

		// 매입처 조회 팝업 클릭 후 리턴
		function setSearchClientInfo(row) {
			$M.setValue("s_cust_name", row.cust_name);
		}
		
		// 조회
		function goSearch() { 
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}

		// 매입처조회
		function fnSearchClientComm() {
			var param = {
				's_cust_name' : $M.getValue('s_cust_name')
			};
			openSearchClientPanel('setSearchClientInfo', 'comm', $M.toGetParam(param));
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_part_no", "s_part_name", "s_cust_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		
		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : true,
				// Row번호 표시 여부
				showRowNumColumn: true,
				// 필터기능 활성여부
				enableFilter : true,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				editable : true,
			};
			var columnLayout = [
				{
					headerText: "부품정보",
					children : [
						{
							dataField: "maker_cd",
							visible : false
						},
						{
							dataField: "deal_cust_no",
							visible : false
						},
						// {
						// 	dataField: "part_group_cd",
						// 	visible : false
						// },
						{
							headerText : "부품번호",
							dataField : "part_no",
							style : "aui-center aui-popup",
							width : "105",
							editable : false,
						},
						{
							headerText : "부품명",
							dataField : "part_name",
							style : "aui-center",
							width : "105",
							editable : false,
							
						},
						{
							headerText : "메이커",
							dataField : "maker_name",
							style : "aui-center",
							width : "85",
							editable : false,
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "매입처",
							dataField : "deal_cust_name",
							style : "aui-center",
							width : "85",
							editable : false,
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "현재고",
							dataField : "current_stock",
							style : "aui-center",
							width : "85",
							dataType : "numeric",
							formatString : "#,##0",
							editable : false,
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "분류구분",
							dataField : "part_group_cd",
							style : "aui-center",
							width : "70",
							editable : false,
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "최종입고일",
							dataField : "last_in_dt",
							dataType: "date",
							formatString: "yyyy-mm-dd",
							style : "aui-center",
							width : "85",
							editable : false,
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "최종입고년도",
							headerStyle : "aui-fold",
							dataField : "last_in_year",
							dataType: "date",
							formatString: "yyyy",
							style : "aui-center",
							width : "95",
							editable : false,
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "최종출고일",
							dataField : "last_sale_dt",
							dataType: "date",
							formatString: "yyyy-mm-dd",
							style : "aui-center",
							width : "85",
							editable : false,
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "최종출고년도",
							headerStyle : "aui-fold",
							dataField : "last_sale_year",
							dataType: "date",
							formatString: "yyyy",
							style : "aui-center",
							width : "95",
							editable : false,
							filter : {
								showIcon : true
							}
						},
					]
				},
				{
					headerText: "관리구분",
					children: [
						{
							dataField: "origin_part_mng_cd",
							visible : false
						},
						{
							dataField: "part_mng_cd",
							visible : false
						},
						{
							headerText : "현재관리구분",
							dataField : "origin_part_mng_name",
							style : "aui-center",
							width : "105",
							editable : false,
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "변경관리구분",
							dataField : "part_mng_name",
							style : "aui-center aui-as-tot-row-style",
							width : "105",
							editable : false,
							filter : {
								showIcon : true
							},
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								value = "";
								switch (item.part_mng_cd) {
									case "1" : value = "정상부품";
										break;
									case "7" : value = "장기재고";
										break;
									case "20" : value = "충당재고";
										break;
									case "99" : value = "폐기대상";
										break;
								}
								return value;
							},
						},
					]
				},
				{
					headerText: "재고금액관리",
					headerStyle : "aui-fold",
					children: [
						{
							headerText : "현평균매입가",
							headerStyle : "aui-fold",
							dataField : "origin_in_avg_price",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							width : "85",
							editable : false,
							
						},
						{
							headerText : "현재고금액",
							headerStyle : "aui-fold",
							dataField : "stock_amt",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							width : "75",
							editable : false,
							
						},
						{
							headerText : "충당금단가",
							headerStyle : "aui-fold",
							dataField : "provision_price",
							dataType : "numeric",
							formatString : "#,###",
							style : "aui-right",
							width : "85",
							editable : false,
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								if(item.part_mng_cd == "20"){
									var value = Math.round(item.origin_in_avg_price * 0.7); //충당재고: 평균매입가 * 0.7(정수로 반올림)
									return value;
								}

							},
							
						},
						{
							headerText : "충당제외단가",
							headerStyle : "aui-fold",
							dataField : "except_provision_price",
							dataType : "numeric",
							formatString : "#,###",
							style : "aui-right",
							width : "85",
							editable : false,
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								if(item.part_mng_cd == "20") {
									var value = item.origin_in_avg_price - Math.round(item.origin_in_avg_price * 0.7); // 충당재고: 평균매입가 - 충당금단가
									return value;
								}
							},
							
						},
						{
							headerText : "변경평균매입가",
							headerStyle : "aui-fold",
							dataField : "in_avg_price",
							dataType : "numeric",
							formatString : "#,###",
							style : "aui-right",
							width : "90",
							editable : false,
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								if(item.origin_part_mng_cd != item.part_mng_cd && item.part_mng_cd == 20){ // 기존관리구분과 변경관리구분이 다를때만 노출
									var value = item.origin_in_avg_price - Math.round(item.origin_in_avg_price * 0.7); // 충당제외단가
									return value;
								}
							},
						},
						{
							headerText : "최종재고금액",
							headerStyle : "aui-fold",
							dataField : "final_stock_amt",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							width : "85",
							editable : false,
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								var value = 0;
								if(item.part_mng_cd == '20'){
									value = (item.origin_in_avg_price - Math.round(item.origin_in_avg_price * 0.7)) * item.current_stock; // 충당재고: 충당제외단가 * 현재고
								}else if(item.part_mng_cd == '99'){
									value = 0;
								}else {
									value = item.origin_in_avg_price * item.current_stock;
								}
								return value;
							},
						},
					]
				},
				{
					headerText: "판매가관리",
					children: [
						{
							headerText : "산출구분",
							dataField : "part_output_price_cd",
							style : "aui-center",
							width : "65",
							editable : false,
							
						},
						{
							headerText : "현판매가",
							dataField : "origin_vip_sale_price",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
							width : "85",
							editable : false,
							
						},
						{
							headerText : "변경판매가",
							dataField : "vip_sale_price",
							dataType : "numeric",
							formatString : "#,###",
							style : "aui-right",
							width : "85",
							editable : false,
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								if(item.strategy_price > 0 && AUIGrid.isEditedCell(auiGrid, item.part_no, "strategy_price")){ // 전략가 수정됐으면 전략가
									return item.strategy_price
								}else if(item.origin_part_mng_cd != item.part_mng_cd || item.part_mng_cd == '20'){ // 기존관리구분과 변경관리구분이 같거나 변경관리구분이 충당재고가 아니면 ""리턴
									for(var i=0; i<marginList.length; i++){
										if(item.part_output_price_cd.substr(3,4) == marginList[i].code_value){
											return Math.round(item.except_provision_price / Number(marginList[i].code_name)); // 충당제외단가 / 마진율
										}
									}
								}else{
									return "";
								}
							},
							
						},
						{
							headerText : "전략가",
							dataField : "strategy_price",
							dataType : "numeric",
							formatString : "#,##0",
							editable : true,
							style : "aui-right aui-editable",
							width : "85",
							editRenderer : {
								type : "InputEditRenderer",
								min : 0,
								onlyNumeric : true,
								// 에디팅 유효성 검사
								validator : AUIGrid.commonValidator
							}
						},
					]
				},
				{
					headerText: "마스터적용일",
					dataField: "apply_date",
					style : "aui-center",
					width : "105",
					editable : false,
					
				},
				{
					headerText: "비고",
					dataField: "remark",
					style : "aui-center aui-editable",
					width : "200",
					editable : true,
				},
				{
					dataField: "apply_yn",
					visible : false,
				},
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			
			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "part_no") {
					var param = {
						part_no : event.item.part_no
					};
					var poppupOption = "";
					$M.goNextPage('/part/part0701p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
			
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
		
		function fnSearch(successFunc) {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			};
			isLoading = true;
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_search_dt_type : $M.getValue("s_search_dt_type"), // 조회날짜 타입
				s_maker_cd : $M.getValue("s_maker_cd"),
				s_machine_plant_seq : $M.getValue("s_machine_plant_seq"),
				s_part_no : $M.getValue("s_part_no"),
				s_part_name : $M.getValue("s_part_name"),
				s_part_mng_cd : $M.getValue("s_part_mng_cd"),
				s_cust_name : $M.getValue("s_cust_name"),
				s_stock_yn : $M.getValue("s_stock_yn"), // 재고여부
				s_temp_yn : $M.getValue("s_temp_yn"), // 임시저장보기 여부
				page : page,
				rows : $M.getValue("s_rows")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			);
		}
		
		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y"  && isLoading == false) {
				goMoreData();
			};
		}
		
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;  
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}
		
		// 임시저장
		function goTempSave() {
			goSave("temp_save");
		}
		// 마스터 적용
		function goModify() {
			goSave("master_apply")
		}
		
		// 저장
		function goSave(type) {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length == 0) {
				alert("선택된 항목이 없습니다.");
				return false;
			}
			// 변경내역 확인
			var editedItems = AUIGrid.getEditedRowColumnItems(auiGrid); // 실제 수정된 row
			var partMngCdModifyFlag = false; // 기존 관리구분과 변경관리구분이 다른 row가 있는지 체크
			

			
			var msg = "";
			var saveMode = "";

			switch (type) {
				case "master_apply": // 마스터 적용
					msg = "부품마스터에 적용하시겠습니까? \n폐기대상인 부품은 재고조정을 통한 폐기처리 이후\n관리구분이 매출정지로 변경됩니다.";
					saveMode = type;
					break;
				case "temp_save": // 임시저장
					msg = "임시저장하시겠습니까?";
					saveMode = type;
					break;
			}
			
			var partNoArr = [];
			var seqNoArr = [];
			var partMngCdArr = [];
			var strategyPriceArr = [];
			var remarkArr = [];
			var vipSalePriceArr = [];
			for (var i = 0; i < rows.length; ++i) {
				if(rows[i].part_mng_cd == ""){
					alert("변경관리구분을 확인해주세요.");
					return false;
				}
				partNoArr.push(rows[i].part_no);
				seqNoArr.push(rows[i].seq_no);
				partMngCdArr.push(rows[i].part_mng_cd);
				strategyPriceArr.push(rows[i].strategy_price);
				remarkArr.push(rows[i].remark);
				vipSalePriceArr.push(rows[i].vip_sale_price);
				if(rows[i].origin_part_mng_cd != rows[i].part_mng_cd){
					partMngCdModifyFlag = true;
				}
			}

			if (editedItems.length == 0 && partMngCdModifyFlag == false) {
				alert("변경된 내역이 없습니다.");
				return;
			}
			
			var option = {
				isEmpty : true
			};
			var param = {
				save_mode : saveMode,
				part_no_str : $M.getArrStr(partNoArr, option),
				seq_no_str : $M.getArrStr(seqNoArr, option),
				part_mng_cd_str : $M.getArrStr(partMngCdArr, option), // 변경관리구분
				strategy_price_str : $M.getArrStr(strategyPriceArr, option), // 전략가
				remark_str : $M.getArrStr(remarkArr, option), // 비고(t_part_mng_temp)
				part_remark_str : $M.getArrStr(remarkArr, option), // 비고(t_part)
				vip_sale_price_str : $M.getArrStr(vipSalePriceArr, option), // 변경판매가(최종vip판매가)
				isPriceEdited : true,
			}
			$M.goNextPageAjaxMsg(msg, this_page + "/save", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearch();
						}
					}
			);
		}
		
		function goTempSaveCancel() {
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			var msg = "임시저장을 취소하시겠습니까?"
			if(rows.length == 0) {
				alert("선택된 항목이 없습니다.");
				return false;
			}

			
			var partNoArr = [];
			var seqNoArr = [];
			var applyYnArr = [];
			
			for (var i = 0; i < rows.length; ++i) {
				if(rows[i].apply_yn == "N"){ // 마스터적용안된 임시저장건
					partNoArr.push(rows[i].part_no);
					seqNoArr.push(rows[i].seq_no);
					applyYnArr.push(rows[i].apply_yn);	
				}
			}
			
			// 임시저장된 부품이 있는지 확인
			if(partNoArr.length == 0){
				alert("임시저장된 데이터가 없습니다.");
				return false;
			}
			
			var option = {
				isEmpty : true
			};
			
			var param = {
				part_no_str : $M.getArrStr(partNoArr, option),
				seq_no_str : $M.getArrStr(seqNoArr, option),
				apply_yn_str : $M.getArrStr(applyYnArr, option),
			}
			
			$M.goNextPageAjaxMsg(msg, this_page + "/tempSaveCancel", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearch();
						}
					}
			);
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGrid, "장기/충당/폐기부품관리", exportProps);
		}
		
		//일괄변경
		function goApplyInfo() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			// 체크한 row 정보
			var checkedItems = AUIGrid.getCheckedRowItems(auiGrid);
			var param = {};
			for(var i in checkedItems){
				var param = {};
				if($M.getValue("temp_part_mng_cd") != ""){
					param.part_mng_cd = $M.getValue("temp_part_mng_cd"); // 변경관리구분코드
					param.temp_part_mng_name = $("#temp_part_mng_cd option:selected").text();; // 변경관리구분명
				}
				if($M.getValue("strategy_price_rate") != "" && checkedItems[i].item.origin_vip_sale_price > 0){
					var remainder = 0;
					var calPartPrice = 0;
					var value = checkedItems[i].item.origin_vip_sale_price * Number($M.getValue("strategy_price_rate")) / 100; // 현판매가에 전략가% 적용
					// 부품마스터과 동일하게 전략가 산출하여 적용
					if(value < 10000){
						remainder = value % 1000 <= 500 ? 0.5 : 1;
						remainder = value % 1000 <= 0 ? 0 : remainder ;
						calPartPrice = (Math.floor(value/1000) + remainder) * 1000;
					} else if(value > 10000000){
						remainder = value % 100000 == 0 ? 0 : 1;
						calPartPrice = (Math.floor(value/100000) + remainder) * 100000;
					} else if(value > 1000000){
						remainder = value % 10000 == 0 ? 0 : 1;
						calPartPrice = (Math.floor(value/10000) + remainder) * 10000;
					} else{
						remainder = value % 1000 == 0 ? 0 : 1;
						calPartPrice = (Math.floor(value/1000) + remainder) * 1000;
					}
					param.strategy_price = calPartPrice;
				}
				if($M.getValue("temp_remark") != ""){
					param.remark = $M.getValue("temp_remark"); // 비고
				}
				AUIGrid.updateRow(auiGrid, param, checkedItems[i].rowIndex);
			}
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
	<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
	<!-- /메인 타이틀 -->
			<div class="contents">
	<!-- 검색영역 -->					
				<div class="search-wrap">				
					<table class="table">
						<colgroup>
							<col width="85px">
							<col width="260px">
							<col width="40px">
							<col width="80px">
							<col width="40px">
							<col width="140px">
							<col width="50px">
							<col width="90px">
							<col width="60px">
							<col width="80px">
							<col width="50px">
							<col width="80px">
							<col width="60px">
							<col width="80px">
							<col width="60px">
							<col width="280px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<td>
									<select class="form-control" id="s_search_dt_type" name="s_search_dt_type" >
										<option value="last_in_dt" selected>최종입고일</option>
										<option value="last_sale_dt">최종출고일</option>
										<option value="apply_dt">마스터적용일</option>
										<option value="all">- 전체 -</option>
									</select>
								</td>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group date-wrap">
												<input type="text" class="form-control border-right-0 calDate " id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="요청 시작일" value="${searchDtMap.s_start_dt }">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group date-wrap">
												<input type="text" class="form-control border-right-0 calDate " id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" alt="요청 종료일" value="${searchDtMap.s_end_dt }">
											</div>
										</div>
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     	</jsp:include>	
									</div>
								</td>
								<th>메이커</th>
								<td>
									<input type="text" style="width : 80px";
										   id="s_maker_cd"
										   name="s_maker_cd"
										   easyui="combogrid"
										   header="Y"
										   easyuiname="makerName"
										   panelwidth="140"
										   maxheight="300"
										   textfield="code_name"
										   multi="Y"
										   enter="goSearch()"
										   idfield="code_value" />
								</td>
								<th>모델명</th>
								<td>
									<input type="text" style="width : 140px"
										   id="s_machine_plant_seq"
										   name="s_machine_plant_seq"
										   easyui="combogrid"
										   header="Y"
										   easyuiname="machineName"
										   panelwidth="140"
										   maxheight="300"
										   textfield="machine_name"
										   multi="Y"
										   enter="goSearch()"
										   idfield="machine_plant_seq" />
								</td>
								<th>매입처</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0" placeholder="" id="s_cust_name" name="s_cust_name" value="">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
									</div>
								</td>
								<th>부품번호</th>
								<td>
									<input type="text" class="form-control" id="s_part_no" name="s_part_no">
								</td>
								<th>부품명</th>
								<td>
									<input type="text" class="form-control" id="s_part_name" name="s_part_name">
								</td>
								<th>관리구분</th>
								<td>
									<select id="s_part_mng_cd" name="s_part_mng_cd" class="form-control">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['PART_MNG']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>재고여부</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="s_stock_n" name="s_stock_yn" value="N" checked="checked">
										<label class="form-check-label" for="s_stock_n">전체</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="s_stock_y" name="s_stock_yn" value="Y">
										<label class="form-check-label" for="s_stock_y">재고있는부품 ㅣ</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_temp_yn" name="s_temp_yn" value="Y">
										<label class="form-check-label" for="s_temp_yn">임시저장보기</label>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
								</td>			
							</tr>										
						</tbody>
					</table>					
				</div>
<!-- /검색영역 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
							<span class="left text-warning" style="margin-left: 50px;">※ 메이커와 모델명 조건은 OR조건으로 조회됩니다.</span>
						<div class="right">
							<label for="s_toggle_column" style="color:black;">
								<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
							</label>
							<span>ㅣ 변경관리구분</span>
							<select class="form-control" id="temp_part_mng_cd" name="temp_part_mng_cd"style="width: 70px; display: inline;">
								<option value="">- 전체 -</option>
								<c:forEach items="${codeMap['PART_MNG']}" var="item">
									<c:if test="${item.code_v2 eq 'Y'}">
										<option value="${item.code_value}">${item.code_name}</option>
									</c:if>
								</c:forEach>
								<option value="99">폐기대상</option>
							</select>
							<span style="margin-left: 10px">전략가</span>
							<input type="text" id="strategy_price_rate" name="strategy_price_rate" placeholder="     %" style="width: 40px; border-radius: 4px;"format="decimal">
							<span style="margin-left: 10px">비고</span>
							<input type="text" id="temp_remark" name="temp_remark" style="width : 180px; border-radius: 4px;">
							
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

				<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
					</div>						
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>		
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>