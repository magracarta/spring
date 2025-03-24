<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품마스터일괄변경 > null > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-03-31 09:01:14
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		let auiGrid;
		let page = 1;
		let moreFlag = "N";
		let isLoading = false;
		let isAsync = true;

		let makerList; // 메이커 리스트
		let realCheckList; // 분류구분 리스트
		let mngList; // 관리구분 리스트
		let dealCustList; // 매입처 리스트
		let outputCdList; // 산출구분 리스트
		
		$(document).ready(function() {
			fnInit();
			createAUIGrid();
		});

		function fnInit() {
			// 메이커 리스트 생성
			makerList = (${codeMapJsonObj['MAKER']}).filter(map => map.code_v2 == 'Y');
			makerList.forEach(item => {
				$("#s_maker_cd").append("<option value='" + item.code_value + "'>" + item.code_name + "</option>");
			});

			// 분류구분 리스트 생성
			realCheckList = ${codeMapJsonObj['PART_REAL_CHECK']};
			realCheckList.forEach(item => {
				$("#s_part_real_check_cd").append("<option value='" + item.code_value + "'>" + item.code_name + "</option>");
			});

			// 관리구분
			mngList = ${codeMapJsonObj['PART_MNG']};
			mngList.forEach(item => {
				$("#s_part_mng_cd").append("<option value='" + item.code_value + "'>" + item.code_name + "</option>");
			});

			// 산출구분 리스트
			outputCdList = ${outputCdList};

			// 매입처 리스트
			dealCustList = ${dealCustList};
		}

		// 그리드 생성
		function createAUIGrid() {
			const gridPros = {
				rowIdField : "part_no",
				rowIdTrustMode : true, // rowIdField가 unique 임을 보장
				showRowNumColumn : true,
				enableFilter : true, // 필터기능 활성여부
				editable : true,
				showStateColumn: true,
			};

			const columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "100",
					style : "aui-center aui-link",
					editable : false,
					required : true,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					width : "130",
					style : "aui-left aui-editable",
					editable : true,
					required : true,
					filter : {
						showIcon : true
					},
					renderer: {
						type: "TemplateRenderer" // HTML 템플릿 렌더러 사용
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (!value) return "";
						return '<div id="part_name_' + rowIndex + '">' + value + '</div>';
					}
				},
				{
					headerText : "",
					dataField : "goHistoryBtn",
					style : "aui-center",
					editable : false,
					width : "40",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							// 부품마스터 변경내역 팝업 호출
							const param = {
								"part_no" : event.item.part_no
							};
							$M.goNextPage("/part/part0708p01", $M.toGetParam(param), {popupStatus : ""});
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return "이력";
					}
				},
				{
					headerText : "메이커",
					dataField : "maker_cd",
					width : "70",
					style : "aui-center aui-editable",
					editable : true,
					filter : {
						showIcon : true
					},
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : true,
						showEditorBtnOver : true,
						list : makerList,
						keyField : "code_value",
						valueField : "code_name",
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						const subList = makerList.filter(map => map.code_value == value);
						return subList.length > 0 ? subList[0].code_name : value;
					}
				},
				{
					headerText : "매입처",
					dataField : "deal_cust_name",
					width : "110",
					style : "aui-left aui-editable",
					editable : true,
					filter : {
						showIcon : true
					},
					editRenderer: {
						type: "DropDownListRenderer",
						showEditorBtnOver: true, // 마우스 오버 시 에디터버턴 보이기
						list: dealCustList,
						keyField : "cust_no",
						valueField : "cust_name",
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						const subList = dealCustList.filter(map => map.cust_no == value);
						return subList.length > 0 ? subList[0].cust_name : value;
					},
				},
				{
					headerText : "고객앱",
					dataField : "app_sale_yn",
					width : "60",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer: {
						type: "DropDownListRenderer",
						list: [{value: "Y", name: "Y"},
								{value: "N", name: "N"}],
						keyField: "value",
						valueField: "name"
					},
				},
				{
					dataField : "deal_cust_no",
					visible : false
				},
				{
					headerText : "분류구분",
					dataField : "part_real_check_cd",
					width : "60",
					style : "aui-center aui-editable",
					editable : true,
					required : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : true,
						showEditorBtnOver : true,
						list : realCheckList,
						keyField : "code_value",
						valueField : "code_name",
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						const subList = realCheckList.filter(map => map.code_value == value);
						return subList.length > 0 ? subList[0].code_name : value;
					}
				},
				{
					headerText : "관리구분",
					dataField : "part_mng_cd",
					width : "85",
					style : "aui-center aui-editable",
					editable : true,
					required : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : true,
						showEditorBtnOver : true,
						list : mngList,
						keyField : "code_value",
						valueField : "code_name",
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						const subList = mngList.filter(map => map.code_value == value);
						return subList.length > 0 ? subList[0].code_name : value;
					}
				},
					// [정윤수] 관리구분 수정여부 체크하기 위하여 추가
				{
					dataField : "origin_part_mng_cd",
					visible : false,
				},
				{
					headerText : "산출구분",
					dataField : "part_output_price_cd",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : true,
						showEditorBtnOver : true,
						list : outputCdList,
						keyField : "code",
						valueField : "calc_foumular",
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						const subList = outputCdList.filter(map => map.code == value);
						return subList.length > 0 ? subList[0].calc_foumular : value;
					}
				},
				{
					headerText : "List Price",
					dataField : "list_price",
					width : "70",
					style : "aui-right aui-editable",
					dataType : "numeric",
					formatString : "#,##0",
					editable : true,
					required : true,
					editRenderer: {
						onlyNumeric : true, // 숫자만
						maxlength: 20,
					}
				},
				{
					headerText : "전략가",
					dataField : "strategy_price",
					width : "70",
					style : "aui-right aui-editable",
					dataType : "numeric",
					formatString : "#,##0",
					editable : true,
					required : true,
					editRenderer: {
						onlyNumeric : true, // 숫자만
						maxlength: 20,
					}
				},
				{
					headerText : "수요예측",
					dataField : "dem_fore_yn",
					width : "80",
					editable : false,
					required : true,
					renderer: {
						type: "TemplateRenderer" // HTML 템플릿 렌더러 사용
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (!value) return "";
						let template = '';
						let checkedYTag = value == 'Y' ? ' checked="checked"' : '';
						let checkedNTag = value == 'N' ? ' checked="checked"' : '';

						template += '<div style="margin-right: 4px;">';
						template += '	<input type="radio" id="dem_fore_y_' + rowIndex + '" name="dem_fore_yn_' + rowIndex + '" onclick="fnSetRadioBtn(event, \'dem_fore_yn\',' + rowIndex + ')" value="Y"' + checkedYTag + '/><label for="dem_fore_y_' + rowIndex + '">Y</label>';
						template += '	<input type="radio" id="dem_fore_n_' + rowIndex + '" name="dem_fore_yn_' + rowIndex + '" onclick="fnSetRadioBtn(event, \'dem_fore_yn\',' + rowIndex + ')" value="N"' + checkedNTag + '/><label for="dem_fore_n_' + rowIndex + '">N</label>';
						template += '</div>';

						return template;
					}
				},
				{
					headerText : "수요예측번호",
					dataField : "dem_fore_no",
					width : "80",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer: {
						maxlength: 25,
					}
				},
				{
					headerText : "신번호",
					dataField : "part_new_no",
					width : "70",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer: {
						maxlength: 25,
					}
				},
				{
					headerText : "구번호",
					dataField : "part_old_no",
					width : "70",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer: {
						maxlength: 25,
					}
				},
				{
					headerText : "주요부품설정",
					dataField : "major_yn",
					width : "80",
					editable : false,
					required : true,
					renderer: {
						type: "TemplateRenderer" // HTML 템플릿 렌더러 사용
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (!value) return "";
						let template = '';
						let checkedYTag = value == 'Y' ? ' checked="checked"' : '';
						let checkedNTag = value == 'N' ? ' checked="checked"' : '';

						template += '<div style="margin-right: 4px;">';
						template += '	<input type="radio" id="major_y_' + rowIndex + '" name="major_yn_' + rowIndex + '" onclick="fnSetRadioBtn(event, \'major_yn\',' + rowIndex + ')" value="' + value + '"' + checkedYTag + '/><label for="major_y_' + rowIndex + '">Y</label>';
						template += '	<input type="radio" id="major_n_' + rowIndex + '" name="major_yn_' + rowIndex + '" onclick="fnSetRadioBtn(event, \'major_yn\',' + rowIndex + ')" value="' + value + '"' + checkedNTag + '/><label for="major_n_' + rowIndex + '">N</label>';
						template += '</div>';

						return template;
					}
				},
				{
					headerText : "교체주기산출여부",
					dataField : "chg_cycle_yn",
					width : "100",
					editable : false,
					required : true,
					renderer: {
						type: "TemplateRenderer" // HTML 템플릿 렌더러 사용
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (!value) return "";
						let template = '';
						let checkedYTag = value == 'Y' ? ' checked="checked"' : '';
						let checkedNTag = value == 'N' ? ' checked="checked"' : '';

						template += '<div style="margin-right: 4px;">';
						template += '	<input type="radio" id="chg_cycle_y_' + rowIndex + '" name="chg_cycle_yn_' + rowIndex + '" onclick="fnSetRadioBtn(event, \'chg_cycle_yn\',' + rowIndex + ')" value="Y"' + checkedYTag + '/><label for="chg_cycle_y_' + rowIndex + '">Y</label>';
						template += '	<input type="radio" id="chg_cycle_n_' + rowIndex + '" name="chg_cycle_yn_' + rowIndex + '" onclick="fnSetRadioBtn(event, \'chg_cycle_yn\',' + rowIndex + ')" value="N"' + checkedNTag + '/><label for="chg_cycle_n_' + rowIndex + '">N</label>';
						template += '</div>';

						return template;
					}
				},
				{
					headerText : "교체주기수기입력",
					dataField : "man_chg_cycle",
					width : "110",
					editable : true,
					dataType : "numeric",
					formatString : "#,##0",
					editRenderer: {
						type: "InputEditRenderer",
						onlyNumeric: true,
						maxlength: 8,
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (item.chg_cycle_yn == "Y") {
							return "aui-editable";
						} else {
							return "aui-center";
						}
						;
					}
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "vScrollChange", function(event) {
				// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청
				if (event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
					goMoreData();
				}
				// 스크롤 시 disable이 풀리는 현상으로 인하여 추가
				fnSetDemForeYn(null);
			});

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// 부품번호 클릭 시, [부품마스터 상세] 팝업 호출
				if (event.dataField == "part_no") {
					const param = {
							part_no : event.item.part_no
					};
					$M.goNextPage('/part/part0701p01', $M.toGetParam(param), {popupStatus : ""});
				}
			});
			AUIGrid.bind(auiGrid, "cellEditBegin", function( event ) {
				if(event.dataField == "man_chg_cycle") {
					if(event.item.chg_cycle_yn != "Y"){
						return false;
					}
				}
			});
			AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
				const dataField = event.dataField;
				// 관리구분 편집 시
				if (dataField == "part_mng_cd") {
					const form = document.getElementsByName("dem_fore_yn_" + event.rowIndex);
					// 정상부품일 경우
					if (event.value == "1") {
						// 수요예측 Y로 변경 및 enable 처리
						AUIGrid.updateRow(auiGrid, {"dem_fore_yn" : "Y"}, event.rowIndex);
						$(form[0]).prop("checked", true);
						$(form[0]).prop("disabled", false);
						$(form[1]).prop("disabled", false);
					} else {
						// 정상부품이 아닐 경우, 수요예측 N으로 변경 및 disable 처리
						AUIGrid.updateRow(auiGrid, {"dem_fore_yn" : "N"}, event.rowIndex);
						$(form[1]).prop("checked", true);
						$(form[0]).prop("disabled", true);
						$(form[1]).prop("disabled", true);
					}

				} else if (dataField == "part_name" || dataField == "part_new_no" || dataField == "part_old_no") {
					// 부품명, 신번호, 구번호 편집 시, 대문자로 변경
					AUIGrid.setCellValue(auiGrid, event.rowIndex, event.dataField, String(event.value).toUpperCase());
				}
				fnSetDemForeYn(null);
			});
		}

		// 수요예측 및 주요부품 라디오버튼 편집 시 실제값 적용
		function fnSetRadioBtn(event, dataField, rowIndex) {
			const target = event.target ? event.target : event.srcElement;
			const value = target.value;
			let item = {};
			item[dataField] = value;
			AUIGrid.updateRow(auiGrid, item, rowIndex);
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			// 제외항목
			const exportProps = {};
			fnExportExcel(auiGrid, "부품마스터 일괄변경", exportProps);
		}

		// 매입처 조회 팝업
		function fnSearchClientComm() {
			const param = {
				s_com_buy_group_cd : "A",
				s_part_search_yn : "Y"
			}
			openSearchClientPanel('fnSetClientInfo', 'comm', $M.toGetParam(param));
		}

		// 매입처 정보 세팅
		function fnSetClientInfo(row) {
			$M.setValue("s_deal_cust_name", row.cust_name);
			$M.setValue("s_deal_cust_no", row.cust_no);
		}

		// 매입처 정보 삭제
		function fnDeleteClientInfo() {
			$M.setValue("s_deal_cust_name", "");
			$M.setValue("s_deal_cust_no", "");
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			const field = ["s_part_no", "s_part_name", "s_maker_cd"];
			field.forEach(name => {
				if (fieldObj.name == name) {
					goSearch();
				}
			});
		}

		// 조회
		function goSearch() {
			if (!$M.getValue('s_part_no') && !$M.getValue('s_part_name') && !$M.getValue('s_maker_cd') && !$M.getValue('s_deal_cust_no')) {
				alert('[부품번호, 부품명, 메이커, 매입처] 중 하나는 필수 입력해주세요.');
				return;
			}
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result) {
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				fnSetDemForeYn(result.list);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				}
			});
		}

		// 조회
		function fnSearch(successFunc) {
			isLoading = true;
			const param = {
				"s_part_no" : $M.getValue("s_part_no"),
				"s_part_name" : $M.getValue("s_part_name"),
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_deal_cust_no" : $M.getValue("s_deal_cust_no"),
				"s_part_real_check_cd" : $M.getValue("s_part_real_check_cd"),
				"s_part_mng_cd" : $M.getValue("s_part_mng_cd"),
				"s_part_output_price_cd" : $M.getValue("s_part_output_price_cd"),
				"s_app_sale_yn" : $M.getValue("s_app_sale_yn"),
				// pageing 처리 파라미터
				"page" : page,
				"rows" : $M.getValue("s_rows")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET', async: isAsync},
				function(result) {
					isLoading = false;
					isAsync = true;
					if (result.success) {
						successFunc(result);
					}
				}
			);
		}

		// 추가 데이터
		function goMoreData() {
			fnSearch(function(result) {
				result.more_yn == "N" ? moreFlag = "N" : page++;
				if (result.list.length > 0) {
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				}
				fnSetDemForeYn(null);
			});
		}

		// 관리구분에 따라 수요예측 N 및 disable 처리
		function fnSetDemForeYn(list) {
			if (!list) {
				list = AUIGrid.getGridData(auiGrid);
			}
			for (let i in list) {
				// 관리구분 = 정상부품이 아닌 경우
				if (list[i].part_mng_cd != "1") {
					const form = document.getElementsByName("dem_fore_yn_" + i);
					AUIGrid.updateRow(auiGrid, {"dem_fore_yn" : "N"}, i);
					$(form[1]).prop("checked", true); // N 체크
					$(form[0]).prop("disabled", "disabled");
					$(form[1]).prop("disabled", "disabled");
				}
			}
		}

		// 저장
		function goSave() {
			// validation
			if (!AUIGrid.validation(auiGrid)) {
				return;
			}

			// 변경내역 확인
			const editedItems = AUIGrid.getEditedRowColumnItems(auiGrid); // 실제 변경된 값
			const editedRowItems = AUIGrid.getEditedRowItems(auiGrid); // 변경된 행의 데이터
			if (editedItems.length == 0) {
				alert("변경된 내역이 없습니다.");
				return;
			}
			if(confirm("저장하시겠습니까?") == false) {
				return;
			}
			// 가격 수정 여부 flag setting
			const isPriceEdited = editedItems.filter(obj => obj.list_price !== "" || obj.strategy_price !== "").length > 0;
			var isMngTempSave = false; // [정윤수] t_part_mng_temp 테이블 이력저장여부
			// [정윤수] 관리구분 충당재고로 변경 시 이력생성하기 위하여 part_mng_cd앞에 modify_ prefix붙임
			for(var i in editedRowItems){
				if(editedRowItems[i].part_mng_cd != editedRowItems[i].origin_part_mng_cd && editedRowItems[i].part_mng_cd == "20"){
					AUIGrid.updateRow(auiGrid, { "part_mng_cd" : "modify_" + editedRowItems[i].part_mng_cd }, editedRowItems[i].row_num - 1);
					isMngTempSave = true;
				}
			}
			const flagFrm = $M.toForm({isPriceEdited : isPriceEdited, isMngTempSave : isMngTempSave});

			// 변경내역 form으로 변경
			const gridFrm = fnChangeGridDataToForm(auiGrid);
			$M.copyForm(gridFrm, flagFrm);
			
			$M.goNextPageAjax(this_page + "/save", gridFrm, {method : 'POST'},
			function(result) {
				if (result.success) {
					isAsync = false;
					goSearch();
					// 변경된 부품명을 붉은색으로 표기
					editedRowItems.forEach(item => $("#part_name_" + (item.row_num - 1)).prop("style", "color: red;"));
				}
			});
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
				<!-- 기본 -->
				<div class="search-wrap">
					<table class="table table-fixed">
						<colgroup>
							<col width="60px">
							<col width="100px">
							<col width="55px">
							<col width="100px">
							<col width="55px">
							<col width="80px">
							<col width="55px">
							<col width="140px"> <!-- 매입처 -->
							<col width="60px">
							<col width="70px"> <!-- 분류구분 -->
							<col width="60px">
							<col width="120px">
							<col width="65px">
							<col width="*"> <!-- 산출구분 -->
							<col width="130px">
							<col width="60px">
						</colgroup>
						<tbody>
							<tr>
								<th>부품번호</th>
								<td>
									<input type="text" class="form-control" id="s_part_no" name="s_part_no"/>
								</td>
								<th>부품명</th>
								<td>
									<input type="text" class="form-control" id="s_part_name" name="s_part_name"/>
								</td>
								<th>메이커</th>
								<td>
									<select class="form-control" id="s_maker_cd" name="s_maker_cd">
										<option value="">- 전체 -</option>
									</select>
								</td>
								<th class="text-right">매입처</th>
								<td>
									<div class="input-group">
										<input type="hidden" id="s_deal_cust_no" name="s_deal_cust_no" alt="매입처번호">
										<input type="text" class="form-control border-right-0" id="s_deal_cust_name" name="s_deal_cust_name" alt="매입처명" readonly="readonly">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="fnSearchClientComm()" style="border-radius: 0 0 0 0;"><i class="material-iconssearch"></i></button>
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="fnDeleteClientInfo()"><i class="material-iconsclose"></i></button>
									</div>
								</td>
								<th>분류구분</th>
								<td>
									<select id="s_part_real_check_cd" name="s_part_real_check_cd" class="form-control">
										<option value="">- 전체 -</option>
									</select>
								</td>
								<th>관리구분</th>
								<td>
									<select id="s_part_mng_cd" name="s_part_mng_cd" class="form-control">
										<option value="">- 전체 -</option>
									</select>
								</td>
								<th class="text-right">산출구분</th>
								<td>
									<select class="form-control width240px" id="s_part_output_price_cd" name="s_part_output_price_cd" alt="산출구분">
										<option value="">- 선택 -</option>
										<c:forEach items="${outputPriceCodeList}" var="item">
											<option value="${item.code}">${item.calc_foumular}</option>
										</c:forEach>
									</select>
								</td>
								<th>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_app_sale_yn" name="s_app_sale_yn" value="Y">
										<label class="form-check-label mr5" for="s_app_sale_yn">고객 앱적용여부</label>
									</div>
								</th>
								<td style="text-align: center;">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch()">조회</button>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- /기본 -->
				<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<!-- /그리드 타이틀, 컨트롤 영역 -->
				<div id="auiGrid" style="margin-top: 5px; height: 563px;"></div>
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