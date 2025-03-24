<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비코드관리 > 장비코드관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-03-25 10:52:36
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGrid;
	var ynList = [ {"code_value":"Y", "code_name" : "Y"}, {"code_value" :"N", "code_name" :"N"}];

	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();
		goSearch();
	});

	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			enableFilter :true,
			editable : true
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
// 			{
// 				headerText: "장비코드",
// 				dataField: "machine_code",
// 				width : "8%",
// 				style : "aui-center aui-editable",
// 			},
			{
				dataField : "machine_plant_seq",
				visible:false
			},
			{
				headerText: "모델명",
				dataField: "machine_name",
				width: "150",
				minWidth: "50",
				style : "aui-left aui-popup",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText: "메이커",
				dataField: "maker_name",
				width: "110",
				minWidth: "50",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText: "판매진행",
				dataField: "sale_yn",
				width: "90",
				minWidth: "30",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "기종명",
				dataField: "machine_type_name",
				width: "110",
				minWidth: "50",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText: "규격",
				dataField: "machine_sub_type_name",
				width: "90",
				minWidth: "30",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "판매가격리스트",
				dataField: "list_sale_price",
				width: "130",
				minWidth: "50",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
			},
			{
				headerText: "최저판매가격",
				dataField: "min_sale_price",
				width: "130",
				minWidth: "50",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
			},
			{
				// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				// headerText: "대리점최저공급가",
				headerText: "위탁판매점최저공급가",
				dataField: "agency_min_sale_price",
				width: "130",
				minWidth: "50",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
			},
			{
				headerText: "프로모션가(본사)",
				dataField: "base_pro_sale_price",
				width: "130",
				minWidth: "50",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
			},
			{
				// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				// headerText: "프로모션공급가(대리점)",
				headerText: "프로모션공급가(위탁판매점)",
				dataField: "agency_pro_sale_price",
				width: "130",
				minWidth: "50",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
			},
			{
				// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				// headerText: "대리점수수료",
				headerText: "위탁판매점수수료",
				dataField: "ma_agency_margin_amt",
				width: "130",
				minWidth: "50",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
			},
			{
				headerText: "할인한도",
				dataField: "max_dc_price",
				width: "130",
				minWidth: "50",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
			},
			{
				headerText: "CAP적용대상",
				dataField: "cap_yn",
				width: "90",
				minWidth: "30",
				style : "aui-center aui-editable",
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : ynList,
					keyField : "code_value",
					valueField : "code_name"
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<ynList.length; i++){
						if(value == ynList[i].code_value){
							return ynList[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText: "SA-R적용대상",
				dataField: "sar_yn",
				width: "90",
				minWidth: "30",
				style : "aui-center aui-editable",
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : ynList,
					keyField : "code_value",
					valueField : "code_name"
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<ynList.length; i++){
						if(value == ynList[i].code_value){
							return ynList[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText: "센터DI적용대상",
				dataField: "center_di_yn",
				width: "90",
				minWidth: "30",
				style : "aui-center aui-editable",
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : ynList,
					keyField : "code_value",
					valueField : "code_name"
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<ynList.length; i++){
						if(value == ynList[i].code_value){
							return ynList[i].code_name;
						}
					}
					return value;
				}
			},
			{
				// [14516] 장비 정렬 순서 사용자가 변경할 수 있도록 변경 - 김경빈
				headerText: "노출순서",
				dataField: "sort_no",
				style : "aui-center aui-editable",
				editable: true,
			},
			{
				headerText: "등록일",
				dataField: "reg_date",
				dataType : "date",
				formatString : "yyyy-mm-dd",
				width: "110",
				minWidth: "50",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "등록자",
				dataField: "reg_mem_name",
				width: "110",
				minWidth: "50",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "사용여부",
				dataField : "use_yn",
				width: "90",
				minWidth: "30",
				style : "aui-center aui-editable",
// 				editable : false,
// 				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 			    	return item['use_yn']=='Y'?'사용':'미사용'
// 				},
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : ynList,
					keyField : "code_value",
					valueField : "code_name"
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<ynList.length; i++){
						if(value == ynList[i].code_value){
							return ynList[i].code_name;
						}
					}
					return value;
				}
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);

		// 셀클릭 - 상세페이지 이동
		AUIGrid.bind(auiGrid, "cellClick", function(event){
			console.log("event : ", event);
			var frm = document.main_form;
			if(event.dataField == "machine_name") {
				var param = {
						machine_plant_seq : event.item.machine_plant_seq
				};
				var poppupOption = "";
				$M.goNextPage('/sale/sale0206p01', $M.toGetParam(param), {popupStatus : poppupOption});
			}
		});

		$("#auiGrid").resize();
	}

	// 조회
	function goSearch() {
		var param = {
				s_machine_plant_seq : $M.getValue("s_machine_plant_seq"),
				s_machine_name : $M.getValue("s_machine_name"),
				s_maker_cd : $M.getValue("s_maker_cd"),
				s_sale_yn : $M.getValue("s_sale_yn"),
				s_use_yn : $M.getValue("s_use_yn"),
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);

	}

	// 장비코드등록 페이지 이동
	function goNew() {
		param = {
				s_sort_key : "machine_plant_seq",
				s_sort_method : "asc"
		};

		$M.goNextPage("/sale/sale020601", $M.toGetParam(param));
	}

	// 엑셀 다운로드
	function fnDownloadExcel() {
	  // 엑셀 내보내기 속성
	  var exportProps = {};
	  fnExportExcel(auiGrid, "장비코드관리", exportProps);
	}

	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_machine_plant_seq", "s_machine_name"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}

	function goSave() {
		var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역

		if (changeGridData.length == 0) {
			alert("변경내역이 없습니다.");
			return;
		}

		var machinePlantSeqArr = [];
		var capYnArr = [];
		var sarYnArr = [];
		var centerDiYnArr = [];
		var useYnArr = [];
		var sortNoArr = []; // 노출순서

		for (var i = 0; i < changeGridData.length; i++) {
			machinePlantSeqArr.push(changeGridData[i].machine_plant_seq);
			capYnArr.push(changeGridData[i].cap_yn);
			sarYnArr.push(changeGridData[i].sar_yn);
			centerDiYnArr.push(changeGridData[i].center_di_yn);
			useYnArr.push(changeGridData[i].use_yn);
			sortNoArr.push(changeGridData[i].sort_no);
		}

		var option = {
				isEmpty : true
		};

		var param = {
				machine_plant_seq_str : $M.getArrStr(machinePlantSeqArr, option),
				cap_yn_str : $M.getArrStr(capYnArr, option),
				sar_yn_str : $M.getArrStr(sarYnArr, option),
				center_di_yn_str : $M.getArrStr(centerDiYnArr, option),
				use_yn_str : $M.getArrStr(useYnArr, option),
				sort_no_str : $M.getArrStr(sortNoArr, option),
		}

		$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			goSearch();
				}
			}
		);
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
						<table class="table">
							<colgroup>
<%-- 								<col width="60px"> --%>
<%-- 								<col width="100px"> --%>
								<col width="60px">
								<col width="100px">
								<col width="60px">
								<col width="100px">
								<col width="70px">
								<col width="100px">
								<col width="70px">
								<col width="100px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>
<!-- 									<th>장비코드</th> -->
<!-- 									<td> -->
<!-- 										<div class="icon-btn-cancel-wrap"> -->
<!-- 											<input type="text" class="form-control" id="s_machine_code" name="s_machine_code"> -->
<!-- 										</div> -->
<!-- 									</td> -->
									<th>모델명</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" class="form-control" id="s_machine_name" name="s_machine_name">
										</div>
									</td>
									<th>메이커</th>
									<td>
										<select id="s_maker_cd" name="s_maker_cd" class="form-control">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>판매진행</th>
									<td>
										<select id="s_sale_yn" name="s_sale_yn" class="form-control">
											<option value="">- 전체 -</option>
											<option value="Y">판매</option>
											<option value="N">미판매</option>
										</select>
									</td>
									<th>사용여부</th>
									<td>
										<select id="s_use_yn" name="s_use_yn" class="form-control">
											<option value="">- 전체 -</option>
											<option value="Y" selected>사용</option>
											<option value="N">미사용</option>
										</select>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /기본 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>장비내역</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->

					<div id="auiGrid" style="margin-top: 5px; height: 600px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
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
