<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 서비스 > 정비불러오기관리 > null > null
-- 작성자 : 이강원
-- 최초 작성일 : 2023-03-23 14:42:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGridLeft;
		var auiGridRight;
		var breakList = JSON.parse('${breakPartListJson}');
		var rentalCheckList = JSON.parse('${rentalCheckListJson}');

		$(document).ready(function() {
			createAUIGridLeft();
			createAUIGridRight();
			fnNewGD();
		});

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_maker_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}

		//조회
		function goSearch() {
			var param = {
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_machine_plant_seq_str" : $M.getValue("s_machine_plant_seq"),
			};

			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							fnNewGD();
							AUIGrid.setGridData(auiGridLeft, result.list);
							AUIGrid.setGridData(auiGridRight, []);
						}
					}
			);
		}

		//모델명 클릭시 클릭시
		function goSearchDetail(mchPlantSeq, makerCd) {
			var param = {
				"s_machine_plant_seq" : mchPlantSeq,
				"s_maker_cd" : makerCd,
			};
			$M.goNextPageAjax(this_page + "/detail", $M.toGetParam(param),{ method : 'get'},
					function(result) {
						if(result.success){
							fnNewGD();
							$M.setValue("machine_plant_seq", mchPlantSeq);
							$M.setValue("maker_cd", makerCd);
							AUIGrid.setGridData(auiGridRight, result.list);
							AUIGrid.addCheckedRowsByValue(auiGridRight, "check_yn", "Y");

							// 정비내용 Setting
							$("#up_job_order_bookmark_seq").html("");
							var jobOrderList = result.list;
							$("#up_job_order_bookmark_seq").append("<option value=''>- 선택 -</option>");
							for(var i = 0 ; i < jobOrderList.length ; i++) {
								if(jobOrderList[i].group_yn != "Y") continue;
								var option = $("<option></option>");
								option.val(jobOrderList[i].job_order_bookmark_seq);
								option.text(jobOrderList[i].order_text);
								$("#up_job_order_bookmark_seq").append(option);
							};
						}
					}
			);
		}

		// 정비목록 클릭 시
		function goSearchContentDetail(jobOrderSeq, isRoot) {
			var param = {
				"job_order_bookmark_seq" : jobOrderSeq,
				"s_machine_plant_seq" : $M.getValue("machine_plant_seq"),
			};
			$M.goNextPageAjax(this_page + "/content/detail", $M.toGetParam(param),{ method : 'get'},
					function(result) {
						if(result.success){
							var param = {};
							fnNewGD(!isRoot);
							if(isRoot) {
								param.job_order_bookmark_seq = result.map.job_order_bookmark_seq;
								param.up_job_order_bookmark_seq = result.map.job_order_bookmark_seq;
								param.order_text = result.map.order_text;
								param.break_part_seq = result.map.break_part_seq;
								param.work_hour = result.map.work_hour;
								param.plan_work_amt = result.map.plan_work_amt;
								param.use_yn = result.map.use_yn;
								param.sort_no = result.map.sort_no;
								param.rental_check_cd = result.map.rental_check_cd;
								param.check_hour = result.map.check_hour;
								// 정비내용상세 - 정비내용에 해당 값 세팅 후 disabled
								$("#up_job_order_bookmark_seq").attr("disabled", true);
								$("#up_job_order_bookmark_seq").removeClass("essential-bg");
							} else {
								param.up_job_order_bookmark_seq = result.map.up_job_order_bookmark_seq;
								param.child_job_order_bookmark_seq = result.map.job_order_bookmark_seq;
								param.detail_order_text = result.map.order_text;
								$("#up_job_order_bookmark_seq").attr("disabled", false);
								$("#up_job_order_bookmark_seq").addClass("essential-bg");
							}

							$M.setValue(param);
							// $("#menu_name").removeClass("essential-bg");
						}
					}
			);
		}

		function goGroupSave() {
			goSaveGD(true);
		}

		function goSave() {
			goSaveGD(false);
		}

		//저장
		function goSaveGD(isGroup) {
			var param;
			var fields;
			if($M.getValue("machine_plant_seq") == "") {
				alert("등록할 장비를 선택해주세요.");
				return false;
			}
			if(isGroup) {
				fields = [
					"order_text", "work_hour", "plan_work_amt", "use_yn"
				]

				param = {
					"machine_plant_seq" : $M.getValue("machine_plant_seq"),
					"maker_cd" : $M.getValue("maker_cd"),
					"job_order_bookmark_seq" : $M.getValue("job_order_bookmark_seq"),
					"order_text" : $M.getValue("order_text"),
					"break_part_seq" : $M.getValue("break_part_seq"),
					"work_hour" : $M.getValue("work_hour"),
					"plan_work_amt" : $M.getValue("plan_work_amt"),
					"use_yn" : $M.getValue("use_yn"),
					"sort_no" : $M.getValue("sort_no"),
				}
			} else {
				if($M.getValue("up_job_order_bookmark_seq") == "") {
					alert("상세내역을 등록할 정비내용을 선택해주세요.");
					return false;
				}

				fields = [
					"detail_order_text"
				]

				param = {
					"machine_plant_seq" : $M.getValue("machine_plant_seq"),
					"maker_cd" : $M.getValue("maker_cd"),
					"job_order_bookmark_seq" : $M.getValue("child_job_order_bookmark_seq"),
					"up_job_order_bookmark_seq" : $M.getValue("up_job_order_bookmark_seq"),
					"order_text" : $M.getValue("detail_order_text"),
					"group_yn" : "N",
				}
			}

			var frm = document.main_form;

			if($M.validation(frm, {field : fields}) == false) {
				return false;
			}

			if(param.job_order_bookmark_seq == "0") {
				$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param), { method : 'POST'},
						function(result) {
							if(result.success) {
								goSearchDetail($M.getValue("machine_plant_seq"), $M.getValue("maker_cd"));
							}
						}
				);
			} else {
				$M.goNextPageAjaxModify(this_page + "/modify", $M.toGetParam(param), { method : 'POST'},
						function(result) {
							if(result.success) {
								goSearchDetail($M.getValue("machine_plant_seq"), $M.getValue("maker_cd"));
							}
						}
				);
			}

		}

		// 삭제
		function goRemove() {
			if($M.getValue("child_job_order_bookmark_seq") == "0") {
				alert("삭제할 정비상세를 선택해주세요.");
				return;
			}

			var param = {
				"job_order_bookmark_seq" : $M.getValue("child_job_order_bookmark_seq"),
				"group_yn" : "N",
				"use_yn" : "N",
			}

			$M.goNextPageAjaxRemove(this_page + "/modify", $M.toGetParam(param), { method : 'POST'},
					function(result) {
						if(result.success) {
							goSearchDetail($M.getValue("machine_plant_seq"), $M.getValue("maker_cd"));
						}
					}
			);
		}

		function fnGroupNew() {
			fnNewGD(true);
		}

		function fnNew() {
			fnNewGD(false);
		}

		//갱신 isGorup (undefined - 전체 초기화, true : 정비설정만 초기화, false : 정비상세 초기화)
		function fnNewGD(isGroup) {
			$("#up_job_order_bookmark_seq").attr("disabled", false);
			$("#up_job_order_bookmark_seq").addClass("essential-bg");
			var param = {};
			// 정비설정 초기화
			// 전체 초기화
			if(isGroup == undefined) {
				param.machine_plant_seq = "";
				param.maker_cd = "";
				param.job_order_bookmark_seq ="0";
				param.order_text = "";
				param.break_part_seq = "";
				param.work_hour = "";
				param.plan_work_amt = "";
				param.use_yn ="Y";
				param.sort_no = "";
				param.child_job_order_bookmark_seq = "0";
				param.up_job_order_bookmark_seq = "";
				param.detail_order_text = "";
			}

			if(isGroup == true) {
				param.job_order_bookmark_seq ="0";
				param.up_job_order_bookmark_seq = "";
				param.order_text = "";
				param.break_part_seq = "";
				param.work_hour = "";
				param.plan_work_amt = "";
				param.use_yn ="Y";
				param.sort_no = "";
			} else if(isGroup == false) {
				// 정비상세 초기화
				param.child_job_order_bookmark_seq = "0";
				param.up_job_order_bookmark_seq = "";
				param.detail_order_text = "";
			}
			param.rental_check_cd = "";
			param.check_hour = "";

			$M.setValue(param);
		}

		//메인그리드
		function createAUIGridLeft() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "_$uid",
				// rowNumber
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				enableFilter :true,
			};
			var columnLayout = [
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "130",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "220",
					style : "aui-center aui-link",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "모델번호",
					dataField : "machine_plant_seq",
					visible : false,
				},
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridLeft, []);
			AUIGrid.bind(auiGridLeft, "cellClick", function(event){
				if (event.dataField == "machine_name") {
					goSearchDetail(event.item.machine_plant_seq, event.item.maker_cd);
				}
			});
		}

		function createAUIGridRight() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "_$uid",
				// No. 생성
				showRowNumColumn: true,
				// 트리 펼치기
				displayTreeOpen : true,
				rowCheckDependingTree : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showSelectionBorder : true,
				treeColumnIndex : 1,
				editable : true,
			};
			var columnLayout = [
				{
					headerText: "생산장비번호",
					dataField : "machine_plant_seq",
					visible : false,
				},
				{
					headerText: "정비내용",
					dataField : "order_text",
					style : "aui-center aui-link",
					width : "250",
					editable : false,
				},
				{
					headerText : "정비분류",
					dataField : "break_part_seq",
					width : "250",
					minWidth : "250",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : true,
						listFunction : function(rowIndex,columnIndex,item){
							if(item.group_yn == 'Y') {
								return breakList;
							} else {
								return [];
							}
						},
						keyField : "break_part_seq",
						valueField : "path_break_part_name",
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						for(var i=0; i<breakList.length; i++) {
							if(value == breakList[i].break_part_seq){
								return breakList[i].path_break_part_name;
							}
						}
						return value;
					}
				},
				{
					headerText : "시간",
					dataField : "work_hour",
					style : "aui-center aui-editable",
					width : "80",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (value == 0) {
							return "";
						}
						return value;
					},
					editable : true,
				},
				{
					headerText: "예상비용",
					dataField: "plan_work_amt",
					dataType: "numeric",
					formatString: "#,##0",
					style : "aui-center aui-editable",
					width: "120",
					minWidth: "100",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (value == 0) {
							return "";
						} else {
							return AUIGrid.formatNumber(value, "#,##0");
						}
					},
					editable : true,
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					style : "aui-center",
					width : "80",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.group_yn != 'Y') {
							return "";
						}
						return value == "Y" ? "사용" : "미사용";
					},
				},
				{
					headerText : "정렬순서",
					dataField : "sort_no",
					style : "aui-center",
					width : "80",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.group_yn != 'Y') {
							return "";
						}
						return value;
					},
					visible: false
				},
				{
					headerText : "작업번호",
					dataField : "job_order_bookmark_seq",
					visible: false,
				},
				{
					headerText : "상위작업번호",
					dataField : "up_job_order_bookmark_seq",
					visible: false,
				},
				{
					headerText : "정비그룹여부",
					dataField : "gruop_yn",
					visible: false,
				},
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);

			// 그리드 갱신
			AUIGrid.setGridData(auiGridRight, []);

			AUIGrid.bind(auiGridRight, "cellClick", function(event){
				if (event.dataField == "order_text") {
					goSearchContentDetail(event.item.job_order_bookmark_seq, event.item.group_yn == 'Y');
				}
			});

			AUIGrid.bind(auiGridRight,  "cellEditBegin", function(event) {
				// 정비상세는 수정 안되게
				if(event.item.group_yn != "Y") {
					return false;
				}
				return true;
			});
		}

		// 메이커 전체의 정비불러오기 수정
		function goChangeSave() {
			var data = AUIGrid.getEditedRowItems(auiGridRight); // 변경내역

			if(data.length == 0) {
				alert("변경된 내역이 없습니다.");
				return;
			}
			var msg = "변경사항이 해당 메이커 정비내용에 반영됩니다.\n수정 하시겠습니까?";

			var frm = fnChangeGridDataToForm(auiGridRight);
			$M.goNextPageAjaxMsg(msg, this_page + "/maker/modify", frm, { method : 'POST'},
					function(result) {
						if(result.success) {
							goSearchDetail($M.getValue("machine_plant_seq"), $M.getValue("maker_cd"));
						}
					}
			);
		}

		// 체크박스 처리만 저장
		function goSaveDetail() {
			var msg = "체크된 정비내용만 해당 모델에 저장됩니다.\n저장 하시겠습니까?";

			var param = {
				now_machine_plant_seq : $M.getValue("machine_plant_seq"),
			}

			var frm = $M.toForm(param);
			var gridFrm = fnCheckedGridDataToForm(auiGridRight);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxMsg(msg, this_page + "/bookmark/mch", gridFrm, { method : 'POST'},
					function(result) {
						if(result.success) {
							alert("저장되었습니다.");
							goSearchDetail($M.getValue("machine_plant_seq"), $M.getValue("maker_cd"));
						}
					})
		}

		// 렌탈장비 이상점검 매핑 적용
		function goApply() {
			if($M.getValue("job_order_bookmark_seq") == "0") {
				alert("정비목록을 선택해주세요.");
				return false;
			}
			// if($M.getValue("rental_check_cd") == "") {
			// 	alert("렌탈 점검사항을 선택해주세요.");
			// 	return false;
			// }
			var param = {
				"machine_plant_seq" : $M.getValue("machine_plant_seq"),
				"job_order_bookmark_seq" : $M.getValue("job_order_bookmark_seq"),
				"rental_check_cd" : $M.getValue("rental_check_cd"),
				"check_hour" : $M.getValue("check_hour")
			}

			var msg = "점검사항 매핑을 적용하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/save/rentalCheck", $M.toGetParam(param), { method : 'POST'},
					function(result) {
						if(result.success) {
							goSearchContentDetail($M.getValue("job_order_bookmark_seq"), true);
						}
					}
			);
		}
	</script>
</head>
<body>
<!-- script -->
<!-- /script -->
<!-- contents 전체 영역 -->
<form id="main_form" name="main_form">
	<input type="hidden" id="cmd" name="cmd" value="C">
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
							<col width="50px">
							<col width="250px">
							<col width="50px">
							<col width="300px">
							<col width="*">
						</colgroup>
						<tbody>
						<tr>
							<th>메이커</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<select class="form-control" id="s_maker_cd" name="s_maker_cd"  >
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${makerList}">
											<option value="${item.maker_cd}">${item.maker_name}</option>
										</c:forEach>
									</select>
								</div>
							</td>
							<th>모델명</th>
							<td>
								<input type="text" style="width : 300px;"
									   id="s_machine_plant_seq"
									   name="s_machine_plant_seq"
									   easyui="combogrid"
									   header="Y"
									   easyuiname="machineList"
									   panelwidth="300"
									   maxheight="300"
									   textfield="machine_name"
									   multi="Y"
									   idfield="machine_plant_seq" />
							</td>
							<td class="">
								<button type="button" onclick="javascript:goSearch();" class="btn btn-important" style="width: 50px;">조회</button>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색영역 -->
				<div class="row">
					<!-- 모델목록 -->
					<div class="col-3">
						<div class="title-wrap mt10">
							<h4>모델목록</h4>
						</div>
						<div id="auiGridLeft" style="margin-top: 5px;height: 635px;"></div>
					</div>
					<!-- /모델목록 -->
					<!-- 정비목록 -->
					<div class="col-6">
						<div class="title-wrap mt10">
							<h4>정비목록</h4>
							<div class="btn-group">
								<div class="right">
									<button type="button" onclick=AUIGrid.expandAll(auiGridRight);
											class="btn btn-default">
										<i class="material-iconsadd text-default"></i>펼침
									</button>
									<button type="button" onclick=AUIGrid.collapseAll(auiGridRight);
											class="btn btn-default">
										<i class="material-iconsremove text-default"></i>접힘
									</button>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
								</div>
							</div>
						</div>
						<div id="auiGridRight" style="margin-top: 5px;height: 635px;"></div>
					</div>
					<!-- /정비목록 -->
					<!-- 정비정보 -->
					<div class="col-3">
						<div class="row">
							<div class="col-12">
								<!-- 정비설정 -->
								<div class="title-wrap mt10">
									<h4>정비설정(수정중)</h4>
								</div>
								<div style="margin-top: 5px;">
									<table class="table-border">
									<colgroup>
										<col width="120px">
										<col width="">
									</colgroup>
									<tbody>
									<tr>
										<th class="text-right essential-item">그룹명</th>
										<td>
											<div class="btn-group">
												<div class="left">
													<input type="text" class="form-control essential-bg width300px" id="order_text" name="order_text" alt="그룹명">
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">정비분류</th>
										<td>
											<input type="text" style="width : 180px;"
												   id="break_part_seq"
												   name="break_part_seq"
												   easyui="combogrid"
												   header="Y"
												   easyuiname="breakPartList"
												   panelwidth="300"
												   maxheight="300"
												   textfield="path_break_part_name"
												   multi="N"
												   idfield="break_part_seq" />
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">시간</th>
										<td>
											<div class="row">
												<div class="col-7">
													<input type="text" id="work_hour" name="work_hour" class="form-control essential-bg width150px" format="decimal" alt="시간">
												</div>
												<div class="col-1" style="line-height: 24px;">hr</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">예상비용</th>
										<td>
											<div class="row">
												<div class="col-6">
													<input type="text" id="plan_work_amt" name="plan_work_amt" class="form-control essential-bg width200px" format="num" alt="금액">
												</div>
												<div class="col-1" style="line-height: 24px;">
													원
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">사용여부</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="use_yn_y" name="use_yn" value="Y" checked="checked">
												<label class="form-check-label" for="use_yn_y">사용</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="use_yn_n" name="use_yn" value="N">
												<label class="form-check-label" for="use_yn_n">미사용</label>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">정렬순서</th>
										<td>
											<input type="text" id="sort_no" name="sort_no" class="form-control essential-bg width180px" format="num" alt="정렬순서">
										</td>
									</tr>
									</tbody>
								</table>
									<div class="btn-group mt5">
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
										</div>
									</div>
								</div>
								<!-- /정비설정 -->
								<!-- 정비상세 -->
								<div class="title-wrap mt10">
									<h4>정비상세</h4>
								</div>
								<div style="margin-top: 5px;">
									<table class="table-border">
										<colgroup>
											<col width="120px">
											<col width="">
										</colgroup>
										<tbody>
										<tr>
											<th class="text-right essential-item">그룹명</th>
											<td>
												<select id="up_job_order_bookmark_seq" name="up_job_order_bookmark_seq" class="form-control essential-bg width280px" style="height:24px; max-width: 280px;" alt="정비상세의 그룹명">
													<option value="">- 선택 -</option>
												</select>
											</td>
										</tr>
										<tr>
											<th class="text-right essential-item">정비내용</th>
											<td>
												<input type="text" id="detail_order_text" name="detail_order_text" class="form-control essential-bg width300px" required="required" alt="정비내용">
											</td>
										</tr>
										</tbody>
									</table>
									<div class="btn-group mt5">
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
										</div>
									</div>
								</div>
								<!-- /정비목록 -->
								<!-- 렌탈장비 이상점검 -->
								<div class="title-wrap mt10">
									<h4>렌탈장비 이상점검</h4>
								</div>
								<div style="margin-top: 5px;">
									<table class="table-border">
										<colgroup>
											<col width="120px">
											<col width="">
										</colgroup>
										<tbody>
										<tr>
											<th class="text-right essential-item">렌탈 점검사항 매핑</th>
											<td>
												<input type="text" style="width : 240px;"
													   id="rental_check_cd"
													   name="rental_check_cd"
													   easyui="combogrid"
													   header="Y"
													   easyuiname="rentalCheckList"
													   panelwidth="300"
													   maxheight="300"
													   textfield="code_name"
													   multi="N"
													   idfield="code_value" />
											</td>
										</tr>
										<tr>
											<th class="text-right">점검시간</th>
											<td>
												<div class="form-row inline-pd widthfix">
													<div class="col width120px">
														<input type="text" id="check_hour" name="check_hour" class="form-control" format="decimal" alt="시간">
													</div>
													<div class="col width22px" style="line-height: 24px;">hr</div>
												</div>
											</td>
										</tr>
										</tbody>
									</table>
									<div class="btn-group mt5">
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BASE_R"/></jsp:include>
										</div>
									</div>
								</div>
								<!-- /렌탈장비 이상점검 -->
								</div>
							</div>
						</div>
					</div>
					<!-- /정비정보 -->
				</div>
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
	<!-- /contents 전체 영역 -->
</form>
</body>
</html>