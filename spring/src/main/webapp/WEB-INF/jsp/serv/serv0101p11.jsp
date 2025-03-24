<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 자주 쓰는 작업
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-24 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGrid;
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
		goSearch();
	});

	function goSearch() {
		var params = {
		};
		$M.goNextPageAjax(this_page + '/search', $M.toGetParam(params), {method : 'GET'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGrid, result.list);
					AUIGrid.expandAll(auiGrid);
				}
			}
		);
	}

	// 펼침
	function fnExpandAll() {
		AUIGrid.expandAll(auiGrid);
	}
	// 접힘
	function fnCollapseAll() {
		AUIGrid.collapseAll(auiGrid);
	}
	
	// function goApplyInfo() {
	function goApply() {
		// 체크된 그리드 데이터
		var itemArr = AUIGrid.getCheckedRowItems(auiGrid);

		// getCheckedRowItems로 data를 가져올 때 rowIndex 순서대로 가져오지 않기 때문에 한 번더 rowIndex 기준으로 정렬
		var sortedData = itemArr.sort(function(a, b) {
			return a.rowIndex - b.rowIndex;
		});


		if(sortedData.length == 0) {
			alert("적용할 데이터를 체크해주세요.");
			return;
		}

		try {
			opener.${inputParam.parent_js_name}(sortedData);
			window.close();
		} catch(e) {
			alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
		}
	}
	
	// 그룹신규
	function fnGroupNew() {
		var params = {
			"up_order_text" : "",
			"up_sort_no" : "1",
			"up_job_order_type_cd" : "REPAIR",
			"up_use_yn" : "Y",
			"up_job_order_bookmark_seq" : "",
			"order_text" : "",
			"plan_work_amt" : "",
			"work_hour" : "",
			"sort_no" : "1",
			"bookmark_type_jr" : "J",
			"use_yn" : "Y"
		};

		$M.setValue(params);
	}

	// 그룹저장
	function goGroupSave() {
		var frm = document.group_form;
		//validationcheck
		if($M.validation(frm,
				{field:["up_order_text", "up_sort_no", "up_use_yn"]}) == false) {
			return;
		};

		var params = {
			"order_text" : $M.getValue("up_order_text"),
			"sort_no" : $M.getValue("up_sort_no"),
			"use_yn" : $M.getValue("up_use_yn"),
			"job_order_type_cd" : "REPAIR",
			"up_job_order_bookmark_seq" : "0",
			"bookmark_type_jr" : "J",
		};

		if ($M.getValue("up_cmd") == "C") {
			$M.goNextPageAjaxSave(this_page + "/group/save", $M.toGetParam(params), {method: 'POST'},
					function (result) {
						if (result.success) {
							location.reload();
						}
					}
			);
		} else {
			goGroupUpdate();
		}
	}

	// 그룹설정 update
	function goGroupUpdate() {
		if (confirm("기존 그룹설정정보를 수정하시겠습니까?") == false) {
			return false;
		}

		var params = {
			"job_order_bookmark_seq" : $M.getValue("job_order_bookmark_seq"),
			"order_text" : $M.getValue("up_order_text"),
			"sort_no" : $M.getValue("up_sort_no"),
			"use_yn" : $M.getValue("up_use_yn")
		};

		$M.goNextPageAjax(this_page + "/group/update", $M.toGetParam(params), { method : 'POST'},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
		);
	}
	
	// 신규
	function fnNew() {
		var params = {
			"up_order_text" : "",
			"up_sort_no" : "1",
			"up_job_order_type_cd" : "REPAIR",
			"up_use_yn" : "Y",
			"up_job_order_bookmark_seq" : "",
			"order_text" : "",
			"plan_work_amt" : "",
			"work_hour" : "",
			"sort_no" : "1",
			"bookmark_type_jr" : "J",
			"use_yn" : "Y"
		};

		$M.setValue(params);
	}

	// 그룹별 상담/점검/정비설정 저장
	function goSave() {
		var frm = document.order_form;
		//validationcheck
		if($M.validation(frm,
				{field:["up_job_order_bookmark_seq", "order_text",
						"plan_work_amt", "work_hour", "sort_no", "use_yn"]}) == false) {
			return;
		};

		var params = {
			"up_job_order_bookmark_seq" : $M.getValue("up_job_order_bookmark_seq"),
			"job_order_type_cd" : "REPAIR",
			"order_text" : $M.getValue("order_text"),
			"plan_work_amt" : $M.getValue("plan_work_amt"),
			"work_hour" : $M.getValue("work_hour"),
			"sort_no" : $M.getValue("sort_no"),
			"bookmark_type_jr" : "J",
			"use_yn" : $M.getValue("use_yn")
		};

		if ($M.getValue("cmd") == "C") {
			$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(params), {method: 'POST'},
				function (result) {
					if (result.success) {
						location.reload();
					}
				}
			);
		} else {
			goUpdate();
		}
	}

	// 그룹별 상담/점검/정비설정 update
	function goUpdate() {
		if (confirm("기존 그룹별  상담/점검/장비설정 정보를 수정하시겠습니까?") == false) {
			return false;
		}

		var params = {
			"job_order_bookmark_seq" : $M.getValue("job_order_bookmark_seq"),
			"up_job_order_bookmark_seq" : $M.getValue("up_job_order_bookmark_seq"),
			"order_text" : $M.getValue("order_text"),
			"plan_work_amt" : $M.getValue("plan_work_amt"),
			"work_hour" : $M.getValue("work_hour"),
			"sort_no" : $M.getValue("sort_no"),
			"use_yn" : $M.getValue("use_yn")
		};

		$M.goNextPageAjax(this_page + "/update", $M.toGetParam(params), { method : 'POST'},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
		);
	}

	function fnRemove() {
		var data = fnCheckedGridDataToForm(auiGrid);

		if(data.length == 0) {
			alert("삭제할 데이터를 체크해주세요.");
			return;
		}

		$M.goNextPageAjaxRemove(this_page + "/remove", data, {method : "POST"},
			function(result) {
				if(result.success) {
					location.reload();
				}
			}
		);
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "job_order_bookmark_seq",
			showRowNumColumn: true,
			// 체크박스 출력 여부
			showRowCheckColumn : true,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : true,
			rowCheckDependingTree : true,
			treeColumnIndex : 0,
		};
		var columnLayout = [
			{
				headerText : "점검 및 정비 지시", 
				dataField : "order_text",
				width : "50%",
				style : "aui-left aui-link",
			},
			{ 
				headerText : "예상비용",
				dataField : "plan_work_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{ 
				headerText : "시간", 
				dataField : "work_hour",
				style : "aui-center",
				dataType : "numeric"
			},
			{ 
				headerText : "사용여부", 
				dataField : "use_yn_name",
				style : "aui-center",
			},
			{ 
				headerText : "정렬순서", 
				dataField : "sort_no",
				style : "aui-center",
			},
			{
				headerText : "지시번호",
				dataField : "job_order_bookmark_seq",
				visible : false
			},
			{
				headerText : "상위지시번호",
				dataField : "up_job_order_bookmark_seq",
				visible : false
			},
			{
				headerText : "사용여부",
				dataField : "use_yn",
				visible : false
			},
			{
				headerText : "작업구분",
				dataField : "bookmark_type_jr",
				visible : false
			},
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();

		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			var params = {
				"job_order_bookmark_seq" : event.item["job_order_bookmark_seq"],
				"up_job_order_bookmark_seq" : event.item["up_job_order_bookmark_seq"]
			};
			goSearchDetail(params);
		});
	}

	//그리드셀 클릭시
	function goSearchDetail(params) {

		$M.goNextPageAjax(this_page + '/search', $M.toGetParam(params), {method : 'GET'},
				function(result) {
					if(result.success) {
						if(result.originList[0].up_job_order_bookmark_seq == 0) {
							fnGroupNew();
							$M.setValue("up_cmd", "U");
							$M.setValue("up_order_text", result.originList[0].order_text);
							$M.setValue("up_sort_no", result.originList[0].sort_no);
							$M.setValue("up_use_yn", result.originList[0].use_yn);
						} else {
							fnNew();
							$M.setValue("cmd", "U");
							$M.setValue("up_job_order_bookmark_seq", result.originList[0].up_job_order_bookmark_seq);
							$M.setValue("order_text", result.originList[0].order_text);
							$M.setValue("plan_work_amt", result.originList[0].plan_work_amt);
							$M.setValue("work_hour", result.originList[0].work_hour);
							$M.setValue("sort_no", result.originList[0].sort_no);
							$M.setValue("use_yn", result.originList[0].use_yn);
						}
					}
				}
		);
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="up_cmd" name="up_cmd" value="C">
<input type="hidden" id="cmd" name="cmd" value="C">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">					
			<div>
<!-- 자주 쓰는 작업 -->
				<div class="row">
					<div class="col-8">
<!-- 상담과 점검/정비 -->		
						<div class="title-wrap">
							<div class="left">
								<h4>상담과 점검/정비</h4>
							</div>
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
							</div>
						</div>
						<div id="auiGrid" style="margin-top: 5px; height: 507px;"></div>
<!-- /상담과 점검/정비 -->	
					</div>
					<div class="col-4">
<!-- 그룹설정 -->
						<form id="group_form" name="group_form">
						<div>
							<div class="title-wrap">
								<h4>그룹설정</h4>
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="90px">
									<col width="">
								</colgroup>
								<tbody>
									
									<tr>
										<th class="text-right essential-item">그룹명</th>
										<td>
											<input type="text" id="up_order_text" name="up_order_text" class="form-control essential-bg" required="required" alt="그룹명">
										</td>			
									</tr>
									<tr>
										<th class="text-right essential-item">정렬순서</th>
										<td>
											<input type="text" id="up_sort_no" name="up_sort_no" dataType="int" placeholder="숫자" class="form-control text-right essential-bg width50px" required="required" alt="정렬순서">
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">사용여부</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="up_use_yn_y" name="up_use_yn" value="Y" checked="checked" required="required" alt="사용여부">
												<label class="form-check-label" for="up_use_yn_y">사용</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="up_use_yn_n" name="up_use_yn" value="N" required="required" alt="사용여부">
												<label class="form-check-label" for="up_use_yn_n">미사용</label>
											</div>
										</td>
									</tr>
								</tbody>
							</table>
							<div class="btn-group mt10">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
								</div>
							</div>
						</div>
						</form>
<!-- /그룹설정 -->	
<!-- 그룹별 상담/점검/정비설정 -->
						<form id="order_form" name="order_form">
						<div>
							<div class="title-wrap">
								<h4>그룹별 상담/점검/정비설정</h4>
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									
									<tr>
										<th class="text-right essential-item">그룹명</th>
										<td>
											<select class="form-control essential-bg width280px" id="up_job_order_bookmark_seq" name="up_job_order_bookmark_seq" alt="상위그룹명"  required="required">
												<option value="" >- 선택 -</option>
												<c:forEach var="item" items="${list}">
													<option value="${item.job_order_bookmark_seq}" >${item.order_text}</option>
												</c:forEach>
											</select>
										</td>			
									</tr>
									<tr>
										<th class="text-right essential-item">점검 및 정비명</th>
										<td>
											<input type="text" id="order_text" name="order_text" class="form-control essential-bg" required="required" alt="점검 및 정비명">
										</td>			
									</tr>
									<tr>
										<th class="text-right essential-item">예상비용</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width90px">
													<input type="text" id="plan_work_amt" name="plan_work_amt" format="decimal" class="form-control text-right essential-bg" required="required" alt="예상비용">
												</div>
												<div class="col width16px">원</div>
											</div>
										</td>			
									</tr>
									<tr>
										<th class="text-right essential-item">시간</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width50px">
													<input type="text" id="work_hour" name="work_hour" format="decimal" class="form-control text-right text-center essential-bg" required="required" alt="시간">
												</div>
												<div class="col width22px">hr</div>
											</div>
										</td>			
									</tr>
									<tr>
										<th class="text-right essential-item">정렬순서</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width40px">
													<input type="text" id="sort_no" name="sort_no" dataType="int" placeholder="숫자" class="form-control text-right essential-bg width50px" required="required" alt="정렬순서">
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">구분</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="use_yn_y" name="use_yn" value="Y" checked="checked" required="required" alt="사용여부">
												<label class="form-check-label" for="use_yn_y">사용</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="use_yn_n" name="use_yn" value="N" required="required" alt="사용여부">
												<label class="form-check-label" for="use_yn_y">미사용</label>
											</div>
										</td>
									</tr>
								</tbody>
							</table>
							<div class="btn-group mt10">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
								</div>
							</div>
						</div>
						</form>
<!-- /그룹별 상담/점검/정비설정 -->
					</div>					
				</div>
<!-- /자주 쓰는 작업 -->
			</div>		
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>