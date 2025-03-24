<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 경쟁사판매가공유 > 타사장비 판매가 등록 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-03-21 16:58:55
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		let auiGridTop;
		let auiGridBottom;

		$(document).ready(function() {

			createAUIGridTop();
            createAUIGridBottom();

			if ("${inputParam.ms_mch_plant_seq}") {
				setMsModelInfo(${data});
			}
		});

		// 닫기
		function fnClose() {
			window.close();
		}

		// 변동판매가 그리드 생성
		function createAUIGridTop() {
			const gridPros = {
				rowIdField : "_$uid",
				showRowNumColum : true,
				editable: true,
				showStateColumn : true,
			};

			const columnLayout = [
				{
					headerText : "변동판매가",
					dataField : "sale_price",
					width : "100",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right aui-editable",
					editable: true,
					required : true,
					editRenderer : {
						onlyNumeric : true,
						maxlength : 20,
						// 에디팅 유효성 검사
						validator : AUIGrid.commonValidator
					},
				},
				{
					headerText : "부서",
					dataField : "org_name",
					width : "60",
					style : "aui-center",
					editable: false,
				},
				{
					headerText : "작성일",
					dataField : "reg_date",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "100",
					style : "aui-center",
					editable: false,
				},
				{
					headerText : "작성자",
					dataField : "reg_name",
					width : "70",
					style : "aui-center",
					editable: false,
				},
				{
					headerText : "비고",
					dataField : "remark",
					style : "aui-left aui-editable",
					editable: true,
					editRenderer : {
						type : "InputEditRenderer",
						maxlength : 50,
						// 에디팅 유효성 검사
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "80",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridTop, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGridTop, { "use_yn" : "N", "cmd" : "U" }, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridTop, "selectedIndex");
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : true
				},
				{
					dataField : "use_yn",
					visible : false
				},
				{
					dataField : "cmd",
					visible : false
				},
				{
					dataField : "",
					visible : false
				},
			];

			auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridTop, []);
			$("#auiGridTop").resize();
		}

		// 경쟁사동향 그리드 생성
		function createAUIGridBottom() {
			const gridPros = {
				rowIdField : "_$uid",
				showRowNumColum : true,
				editable: true,
				showStateColumn : true,
			};

			const columnLayout = [
				{
					headerText : "메이커",
					dataField : "ms_maker_name",
					width : "80",
					style : "aui-center",
					editable: false,
				},
				{
					headerText : "등록일자",
					dataField : "reg_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "100",
					style : "aui-center",
					editable: false,
				},
				{
					headerText : "등록자",
					dataField : "reg_name",
					width : "70",
					style : "aui-center",
					editable: false,
				},
				{
					headerText : "경쟁사동향",
					dataField : "trend_text",
					style : "aui-left aui-editable",
					editable: true,
					required : true,
					editRenderer : {
						type : "InputEditRenderer",
						maxlength : 500,
						// 에디팅 유효성 검사
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "80",
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
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : true
				},
				{
					dataField : "use_yn",
					visible : false
				},
				{
					dataField : "cmd",
					visible : false
				},
				{
					dataField : "ms_mch_sale_trend_seq",
					visible : false
				},
			];

			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridBottom, []);
			$("#auiGridBottom").resize();
		}

		// 저장
		function goSave() {
			// 필수값 체크
			if (!$M.validation(document.main_form)) {
				return false;
			}

			if ($M.getValue("sale_price") == "" && $M.getValue("trend_text") == "" ) {
				alert("경쟁사동향 또는 판매가는 필수입력입니다.");
				return false;
			}

			var msg = "경쟁사 정보를 등록하시겠습니까?";
			const frm = $M.toValueForm(document.main_form);
			$M.goNextPageAjaxMsg(msg, this_page + "/save", $M.toValueForm(frm), {method: 'POST'},
				function (result) {
					if (result.success) {
						if (opener && opener.goSearch) {
							opener.goSearch();
						}
						// 판매가, 비고 초기화 및 그리드 최신화
						$M.setValue("sale_price", "");
						$M.setValue("remark", "");
						$M.setValue("trend_text", "");
						goSearch();
					}
				}
			);
		}

		// 변동판매가, 경쟁사동향 조회
		function goSearch() {
			let param = {
				ms_mch_plant_seq : $M.getValue("ms_mch_plant_seq"),
				ms_maker_cd : $M.getValue("ms_maker_cd"),
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if (result.success && result.list) {
						destroyGrid();
						createAUIGridTop();
						AUIGrid.setGridData(auiGridTop, result.list);

						createAUIGridBottom();
						AUIGrid.setGridData(auiGridBottom, result.trend_list);
					}
				}
			);
		}

		// 변동판매가, 경쟁사동향 수정
		function goModify() {
			var msMchPlantSeq = $M.getValue("ms_mch_plant_seq");
			if (msMchPlantSeq == "") {
				alert("저장할 대상이 없습니다.");
				return;
			}

			if (fnChangeGridDataCnt(auiGridTop) + fnChangeGridDataCnt(auiGridBottom) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			var msg = "변동판매가, 경쟁사동향 입력내역을 수정하시겠습니까?";
			if (confirm(msg) == false) {
				return false;
			}

			var param = {
				"ms_mch_plant_seq" : msMchPlantSeq,
				"ms_maker_cd": $M.getValue("ms_maker_cd")
			}
			var frm = $M.toForm(param);
			var option = {
				isEmpty : true
			};

			var ms_mch_sale_price_seq = [];
			var sale_price = [];
			var remark = [];
			var price_use_yn = [];
			var price_cmd = [];
			var dataEditRows = AUIGrid.getEditedRowItems(auiGridTop);
			var dataRemoveRows = AUIGrid.getRemovedItems(auiGridTop);
			for (var i = 0; i < dataEditRows.length; i++) {
				var row = dataEditRows[i];
				ms_mch_sale_price_seq.push(row.ms_mch_sale_price_seq);
				sale_price.push(row.sale_price);
				remark.push(row.remark);
				price_use_yn.push(row.use_yn);
				price_cmd.push("U");
			}
			for (var i = 0; i < dataRemoveRows.length; i++) {
				var row = dataRemoveRows[i];
				ms_mch_sale_price_seq.push(row.ms_mch_sale_price_seq);
				sale_price.push(row.sale_price);
				remark.push(row.remark);
				price_use_yn.push("N");
				price_cmd.push("U");
			}
			$M.setValue(frm, "ms_mch_sale_price_seq_str", $M.getArrStr(ms_mch_sale_price_seq, option));
			$M.setValue(frm, "sale_price_str", $M.getArrStr(sale_price, option));
			$M.setValue(frm, "remark_str", $M.getArrStr(remark, option));
			$M.setValue(frm, "price_use_yn_str", $M.getArrStr(price_use_yn, option));
			$M.setValue(frm, "price_cmd_str", $M.getArrStr(price_cmd, option));

			var ms_mch_sale_trend_seq = [];
			var trend_text = [];
			var trend_use_yn = [];
			var trend_cmd = [];
			dataEditRows = AUIGrid.getEditedRowItems(auiGridBottom);
			dataRemoveRows = AUIGrid.getRemovedItems(auiGridBottom);
			for (var i = 0; i < dataEditRows.length; i++) {
				var row = dataEditRows[i];
				ms_mch_sale_trend_seq.push(row.ms_mch_sale_trend_seq);
				trend_text.push(row.trend_text);
				trend_use_yn.push(row.use_yn);
				trend_cmd.push("U");
			}
			for (var i = 0; i < dataRemoveRows.length; i++) {
				var row = dataRemoveRows[i];
				ms_mch_sale_trend_seq.push(row.ms_mch_sale_trend_seq);
				trend_text.push(row.trend_text);
				trend_use_yn.push("N");
				trend_cmd.push("U");
			}
			$M.setValue(frm, "ms_mch_sale_trend_seq_str", $M.getArrStr(ms_mch_sale_trend_seq, option));
			$M.setValue(frm, "trend_text_str", $M.getArrStr(trend_text, option));
			$M.setValue(frm, "remark_str", $M.getArrStr(remark, option));
			$M.setValue(frm, "trend_use_yn_str", $M.getArrStr(trend_use_yn, option));
			$M.setValue(frm, "trend_cmd_str", $M.getArrStr(trend_cmd, option));

			$M.goNextPageAjax(this_page + "/modify", frm, {method : 'POST'},
					function(result) {
						if (result.success) {
							goSearch();
						}
					}
			);
		}

		// MS모델조회 콜백 함수
		function setMsModelInfo(row) {
			// 메이커, 모델명 데이터 세팅
			$M.setValue("ms_maker_cd", row.ms_maker_cd);
			$M.setValue("ms_maker_name", row.ms_maker_name);
			$M.setValue("ms_mch_plant_seq", row.ms_mch_plant_seq);
			$M.setValue("ms_mch_name", row.ms_mch_name);

			// 조회
			goSearch();
		}

		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGridTop");
			auiGridTop = null;
			AUIGrid.destroy("#auiGridBottom");
			auiGridBottom = null;
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
			<div class="title-wrap">
				<h4>경쟁사 정보 등록</h4>
			</div>
			<!-- 메이커, 경쟁사동향 테이블 영역 -->
			<table class="table-border">
				<colgroup>
					<col width="30%">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right">메이커</th>
						<td>
							<div class="form-row inline-pd pr">
								<div class="col-auto">
									<div class="input-group">
										<input type="text" id="ms_maker_name" name="ms_maker_name" class="form-control border-right-0 width120px essential-bg" readonly="readonly" required="required" alt="메이커">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="openSearchMsModelPanel('setMsModelInfo', 'N');"><i class="material-iconssearch"></i></button>
										<input type="hidden" id="ms_mch_plant_seq" name="ms_mch_plant_seq">
										<input type="hidden" id="ms_maker_cd" name="ms_maker_cd">
									</div>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">경쟁사동향</th>
						<td>
							<textarea class="form-control"  id="trend_text" name="trend_text" style="height: 78px;" maxlength="250"></textarea>
						</td>
					</tr>
				</tbody>
			</table>
			<!-- 변동판매가 테이블 영역 -->
			<table class="table-border mt20">
				<colgroup>
					<col width="30%">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right">모델명</th>
						<td>
							<input type="text" class="form-control width145px" id="ms_mch_name" name="ms_mch_name" readonly="readonly">
						</td>
					</tr>
					<tr>
						<th class="text-right">판매가</th>
						<td>
							<div class="form-row" style="margin-left: 0px;">
								<input type="text" class="form-control text-right width130px mr5" id="sale_price" name="sale_price" format="num" size="20" maxlength="20" alt="판매가">
								<span>원</span>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">작성자</th>
						<td id="reg_mem_name">
							<c:out value="${SecureUser.user_name}"></c:out>
						</td>
					</tr>
					<tr>
						<th class="text-right">비고</th>
						<td>
							<input type="text" class="form-control" id="remark" name="remark" value="" max="200">
						</td>
					</tr>
				</tbody>
			</table>

			<!-- 우측 중단 버튼 영역 -->
			<div class="btn-group mt5">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
				</div>
			</div>

			<!-- 변동판매가 입력내역 그리드 영역 -->
			<div class="title-wrap mt10">
				<h4>변동판매가 입력내역</h4>
			</div>
			<div id="auiGridTop" style="margin-top: 5px; width: 100%; height: 200px;" ></div>

			<!-- 경쟁사 전체동향보기 -->
			<div class="title-wrap mt10">
				<h4>경쟁사 전체동향보기</h4>
			</div>
			<div id="auiGridBottom" style="margin-top: 5px; width: 100%; height: 200px;" ></div>

			<!-- 우측 하단 버튼 영역 -->
			<div class="btn-group mt5">
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