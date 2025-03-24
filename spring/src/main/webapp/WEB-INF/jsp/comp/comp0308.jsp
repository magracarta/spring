<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include
	page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c"
	uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn"
	uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt"
	uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib
	uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib
	uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 직원연관팝업 > 직원연관팝업 > null > 보유기종조회
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<script type="text/javascript">
	var auiGridTop;
	var auiGridBottom;
	var extMchTotalCnt = 0;

	var makerList = JSON.parse('${codeMapJsonObj['MAKER']}');
	var machineTypeList = JSON.parse('${codeMapJsonObj['MACHINE_TYPE']}');
	var yearList = ${year_list};
	var siljuResonList = JSON.parse('${codeMapJsonObj['SILJU_REASON']}');

	$(document).ready(function() {
		createauiGridTop();
		createauiGridBottom();
	});
		
	function createauiGridTop() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "machine_seq",
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			enableFilter :true,
			enableSorting : false,
			// singleRow 선택모드
			selectionMode : "singleRow",
		};
		
		var columnLayout = [
			{ 
				headerText : "차대번호", 
				dataField : "body_no", 
				width : "14%",
				style : "aui-center aui-popup",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "모델명", 
				dataField : "machine_name", 
				width : "10%",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "엔진번호1", 
				dataField : "engine_no_1", 
				width : "10%", 
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			// {
			// 	headerText : "보유기종",
			// 	dataField : "machine_type_name",
			// 	width : "15%",
			// 	style : "aui-center",
			// 	editable : false,
			// 	filter : {
			// 		showIcon : true
			// 	}
			// },
			{ 
				dataField : "machine_type_cd", 
				visible : false
			},
			{ 
				dataField : "machine_plant_seq", 
				visible : false
			},
			{ 
				dataField : "machine_seq", 
				visible : false
			},
			{ 
				dataField : "machine_sub_type_cd", 
				visible : false
			},
			{ 
				dataField : "maker_cd", 
				visible : false
			},
			// {
			// 	headerText : "규격",
			// 	dataField : "machine_sub_type_name",
			// 	width : "10%",
			// 	style : "aui-center",
			// 	editable : false,
			// 	filter : {
			// 		showIcon : true
			// 	}
			// },
			{ 
				headerText : "메이커", 
				dataField : "maker_name", 
				width : "8%",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "판매일자",
				dataField : "sale_dt",
				width : "8%",
				dataType : "date",
				formatString : "yyyy-mm-dd",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "연식",
				dataField : "made_year",
				width : "6%",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "소개자정보",
				dataField : "cost_cust_name",
				width : "10%",
				style : "aui-center aui-popup",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "현재 상태",
				dataField : "curr_status_name",
				width : "8%",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "만료일자",
				dataField : "expire_dt",
				width : "8%",
				dataType : "date",
				formatString : "yyyy-mm-dd",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "비고", 
				dataField : "remark", 
				style : "aui-left",
				editable : false,
				filter : {
					showIcon : true
				}
			}
		]
		auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridTop, ${list});
		AUIGrid.bind(auiGridTop, "cellClick", function(event){
			if(event.dataField == "body_no") {
				var params = {
						"s_machine_seq" : event.item["machine_seq"]
				};
				
				var popupOption = "";
				$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
			}
			if(event.dataField == "cost_cust_name") {
				var custNo = event.item["cost_cust_no"];
				if (custNo != "") {
					var param = {
						cust_no : custNo
					}
					$M.goNextPage("/cust/cust0102p01", $M.toGetParam(param), {popupStatus : ""});
				}
			}
		});
		$("#auiGridTop").resize();
	}

	function createauiGridBottom() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "_$uid",
			// rowNumber
			showRowNumColumn : true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			enableFilter :true,
			enableSorting : false,
			editable : true,
			showStateColumn : true
		};

		var columnLayout = [
			{
				dataField : "ext_mch_seq",
				visible : false
			},
			{
				headerText : "메이커",
				dataField : "maker_cd",
				width : "10%",
				style : "aui-center aui-editable",
				editable : true,
				filter : {
					showIcon : true
				},
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : true,
					showEditorBtnOver : true,
					editable : true,
					required : true,
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
				headerText : "모델명",
				dataField : "machine_name",
				width : "12%",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
					type : "InputEditRenderer",
					maxlength : 50,
					// 에디팅 유효성 검사
					validator : AUIGrid.commonValidator
				},
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "기종",
				dataField : "machine_type_cd",
				width : "12%",
				style : "aui-center aui-editable",
				editable : true,
				filter : {
					showIcon : true
				},
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : true,
					showEditorBtnOver : true,
					editable : true,
					required : true,
					list : machineTypeList,
					keyField : "code_value",
					valueField : "code_name",
				},
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					const subList = machineTypeList.filter(map => map.code_value == value);
					return subList.length > 0 ? subList[0].code_name : value;
				}
			},
			{
				headerText : "규격",
				dataField : "mch_sub_type",
				width : "10%",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
					type : "InputEditRenderer",
					maxlength : 50,
					// 에디팅 유효성 검사
					validator : AUIGrid.commonValidator
				},
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "연식",
				dataField : "made_year",
				width : "8%",
				style : "aui-center aui-editable",
				editable : true,
				filter : {
					showIcon : true
				},
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : true,
					showEditorBtnOver : true,
					editable : true,
					required : true,
					list : yearList,
					keyField : "year_col",
					valueField : "year_col",
				},
			},
			{
				headerText : "고객구매가",
				dataField : "mch_price",
				width : "10%",
				style : "aui-right aui-editable",
				editable : true,
				dataType : "numeric",
				formatString : "#,##0",
				editRenderer : {
					type : "InputEditRenderer",
					onlyNumeric : true,
					auiGrid : "#auiGridBottom",
					maxlength : 20
				},
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "실주원인",
				dataField : "silju_reason_cd",
				width : "12%",
				style : "aui-center aui-editable",
				editable : true,
				filter : {
					showIcon : true
				},
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : true,
					showEditorBtnOver : true,
					editable : true,
					required : true,
					list : siljuResonList,
					keyField : "code_value",
					valueField : "code_name",
				},
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					const subList = siljuResonList.filter(map => map.code_value == value);
					return subList.length > 0 ? subList[0].code_name : value;
				}
			},
			{
				headerText : "비고",
				dataField : "remark",
				style : "aui-left aui-editable",
				editable : true,
				editRenderer : {
					type : "InputEditRenderer",
					maxlength : 200,
					// 에디팅 유효성 검사
					validator : AUIGrid.commonValidator
				},
				filter : {
					showIcon : true
				}
			},
			{
				width : "5%",
				headerText : "삭제",
				dataField : "removeBtn",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGridBottom, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.updateRow(auiGridBottom, { "use_yn" : "N", "cmd" : "U" }, event.rowIndex);
							AUIGrid.removeRow(event.pid, event.rowIndex);
						} else {
							AUIGrid.restoreSoftRows(auiGridBottom, "selectedIndex");
						}
						var total = AUIGrid.getGridData(auiGridBottom).length;
						$("#ext_mch_total_cnt").html(total);
					},
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false
			},
			{
				dataField : "use_yn",
				visible : false,
			},
			{
				dataField : "cmd",
				visible : false,
			},
		]
		auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridBottom, ${ext_mch_list});
		$("#auiGridBottom").resize();
	}

	// 보유기종 조회
	function goSearch() {
        var param = {
            "cust_no": $M.getValue("cust_no"),
            "s_history_yn" : $M.getValue("s_history_yn") == ""? "N" : $M.getValue("s_history_yn")
        };
        $M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
            function(result) {
                if(result.success) {
                    AUIGrid.setGridData(auiGridTop, result.list);
                    $("#total_cnt").html(result.total_cnt);
                }
            }
        );
	}

	// 외부차량 조회
	function goExtMchSearch() {
		var param = {
			"cust_no": $M.getValue("cust_no"),
		};
		$M.goNextPageAjax(this_page + '/ext_mch/search', $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGridBottom, result.ext_mch_list);
						$("#ext_mch_total_cnt").html(result.ext_mch_total_cnt);
					}
				}
		);
	}

	// 외부차량 행추가
	function fnAdd() {
		if(fnCheckGridEmpty(auiGridBottom)) {
			var item = new Object();
			item.ext_mch_seq = '0'
			item.model_name = '';
			item.maker_cd = '';
			item.mch_sub_type = '';
			item.made_year = '';
			item.mch_price = '0';
			item.silju_reason_cd = '01';
			item.use_yn = 'Y';
			AUIGrid.addRow(auiGridBottom, item, 'last');

			var total = AUIGrid.getGridData(auiGridBottom).length;
			$("#ext_mch_total_cnt").html(total);
		}
	}

	// 그리드 벨리데이션
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGridBottom, ["maker_cd", "machine_name", "machine_type_cd"], "필수 항목은 반드시 값을 입력해야합니다.");
	}

	// 외부차량정보 저장
	function goSave() {
		if(!fnCheckGridEmpty(auiGridBottom)) {
			return false;
		}
		if (fnChangeGridDataCnt(auiGridBottom) == 0){
			alert("변경된 데이터가 없습니다.");
			return false;
		}

		var frm = $M.toValueForm(document.main_form);
		var gridFrm = fnChangeGridDataToForm(auiGridBottom);
		$M.copyForm(gridFrm, frm);

		$M.goNextPageAjaxSave(this_page+"/save", gridFrm, {method : 'post'},
				function(result) {
					if(result.success) {
						goExtMchSearch();
					}
				}
		);
	}

	//팝업 끄기
	function fnClose() {
		window.close(); 
	}
	
</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
		<input type="hidden" name="cust_no" id="cust_no" value="${inputParam.cust_no}">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<div class="title-wrap">
					<h4>보유기종</h4>
					<div class="right">
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="checkbox" id="s_history_yn" name="s_history_yn" value="Y" onchange="javascript:goSearch()"/>
							<label class="form-check-input" for="s_history_yn">과거장비확인</label>
						</div>
					</div>
				</div>

				<div id="auiGridTop" style="margin-top: 5px; height: 285px;"></div>
				
				<div class="btn-group mt5">		
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
					</div>
				</div>
			</div>
			<div class="content-wrap">
				<div class="title-wrap">
					<h4>미 등록 고객장비(외부차량)</h4>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGridBottom" style="margin-top: 5px; height: 285px;"></div>

				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="ext_mch_total_cnt">${ext_mch_total_cnt}</strong>건
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