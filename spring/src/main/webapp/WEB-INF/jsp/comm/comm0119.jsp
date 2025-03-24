<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 공지관리
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-03-30 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var orgCodeArr = [];
		var jobCdArr = [];
		var gradeCdArr = [];
		
		var upMenuCodeDom;
		
		var auiGridCategory;
		var auiGridOrg;
		var auiGridGrade;
		var auiGridJob;
		
		$(document).ready(function() {
			upMenuCodeDom = $("#up_menu_code");
			createAUIGridCategory();
			goSearch();
			goUpCategorySearch();
			clear();
			createAUIGridOrg();
			createAUIGridGrade();
			createAUIGridJob();
		});
		
		function fnUpMenuAction() {
			var upMenuChk = $("input:checkbox[id='up_menu_chk']").is(":checked");
			if(upMenuChk) {
				$("#up_menu_code").attr("disabled",true);
				$("#up_menu_code").attr("class","readonly"); 
			} else {
				$("#up_menu_code").attr("disabled",false);
				$("#up_menu_code").attr("class","");
			};
		}
		
		function fnNew() {
			clear();
			$M.setValue("up_menu_chk", "N");
			fnUpMenuAction();
			
			$("#menu_code").attr("disabled",false);
			$("#menu_code").addClass("essential-bg");
		}
		
		// 저장(control : C 신규저장 / control : U 수정)
		function goSave() {
			
			var frm = document.main_form;
			
			if($M.validation(frm) == false) {
				return;
			};
			
			var upMenuChk = $("input:checkbox[id='up_menu_chk']").is(":checked");
			if (upMenuChk == false && $M.getValue("up_menu_code") == "") {
				alert("상위 카테고리는 필수입니다.");
				$("#up_menu_code").focus();
				return false;
			}
			
			if ($M.getValue("use_yn") == "") {
				alert("사용여부는 필수입니다.");
				return false;
			}
			
			var control = $M.getValue("control");
			if (control == "") {
				return false;
			}
			if (control == "C") {
				if (confirm("신규 카테고리를 등록하시겠습니까?") == false) {
					return false;
				}
			} else {
				if (confirm("기존 카테고리를 수정하시겠습니까?") == false) {
					return false;
				}
			}
			
			var orgList = AUIGrid.getCheckedRowItemsAll(auiGridOrg);
			var orgArray = [];
			for (var i = 0; i < orgList.length; ++i) {
				orgArray.push(orgList[i].org_code);
			}
			
			// 조상선택
			for (var i = 0; i < orgList.length; ++i) {
				var ascendList = AUIGrid.getAscendantsByRowId(auiGridOrg, orgList[i].org_code);
				for (var j = 0; j < ascendList.length; ++j) {
					if (orgArray.indexOf(ascendList[j].org_code) == -1) {
						orgArray.push(ascendList[j].org_code);
					}
				}
			}
			
			var orgCodeStr = $M.getArrStr(orgArray);
			var gradeCdStr = $M.getArrStr(AUIGrid.getCheckedRowItemsAll(auiGridGrade), {key : "grade_cd"});
			var jobCdStr = $M.getArrStr(AUIGrid.getCheckedRowItemsAll(auiGridJob), {key : "job_cd"});
			
			var param = {
				menu_name : $M.getValue("menu_name"),
				menu_code : $M.getValue("menu_code"),
				use_yn : $M.getValue("use_yn"),
				sort_no : $M.getValue("sort_no"),
				after_menu_push : $M.getValue("after_menu_push") == "" ? "N" : "Y",
				up_menu_code : $M.getValue("up_menu_code"),
				up_menu_chk : $M.getValue("up_menu_chk") == "" ? "N" : "Y",
				notice_org_code_str : orgCodeStr,
				grade_cd_str : gradeCdStr,
				job_cd_str : jobCdStr,
				control : $M.getValue("control")
			}
			
			$M.goNextPageAjax(this_page, $M.toGetParam(param), { method : 'post'},
					function(result) {
						if(result.success) {
							goSearch();
							goUpCategorySearch();
						}
					}
				);
		}
		
		function clear() {
			var param = {
				menu_code : "",
				menu_name : "",
				sort_no : "1",
				use_yn : "Y",
				up_menu_code : "",
				control : "C",
				use_yn : "Y",
			}
			$M.setValue(param);
			AUIGrid.setAllCheckedRows(auiGridOrg, false);
			AUIGrid.setAllCheckedRows(auiGridGrade, false);
			AUIGrid.setAllCheckedRows(auiGridJob, false);
		}
		
		// 상세
	   function goDetail(menuCode) {
			if(menuCode == null || menuCode == undefined) {
				menuCode = "";
			}
			var params = {
				"menu_code" : menuCode
			};
			
			clear();
			$M.setValue("control", "U");
			
			$M.goNextPageAjax(this_page + "/detail", $M.toGetParam(params), { method : 'get'},
				function(result) {
					if(result.success) {
						$M.setValue(result.category);
						
						$("#menu_code").attr("disabled",true);
						$("#menu_code").removeClass("essential-bg");
						
						if($M.getValue("up_menu_code") == "") {
							$("#up_menu_chk").prop("checked", true);
							$M.setValue("up_menu_code", "");
	                	} else {
							$("#up_menu_chk").prop("checked", false);
						};
						fnUpMenuAction();
						
						//AUIGrid.setGridData(auiGridOrg, result.originOrgList);
						if (result.orgCheckList) {
							AUIGrid.setCheckedRowsByIds(auiGridOrg, result.orgCheckList);
						}
						AUIGrid.expandAll(auiGridOrg);
						
						//AUIGrid.setGridData(auiGridGrade, result.originGradeList);
						if (result.gradeCheckList) {
							AUIGrid.setCheckedRowsByIds(auiGridGrade, result.gradeCheckList);
						}
						//AUIGrid.setGridData(auiGridJob, result.originJobList);
						if (result.jobCheckList) {
							AUIGrid.setCheckedRowsByIds(auiGridJob, result.jobCheckList);
						}
					}
				}
			);
		}
		
		// 직급트리
		function createAUIGridJob() {
			var gridPros = {
				rowIdField : "job_cd",
				height : 483,
				displayTreeOpen : false,
				rowCheckDependingTree : true,
				showRowNumColumn : false,
				enableFilter : true,
				showRowCheckColumn: true,
				treeColumnIndex : 0,
			};
			var columnLayout = [ 
			{
				headerText : "직급",
				dataField : "job_name",
				style : "aui-left",
				editable : false,
				width : "200",
				minWidth : "100",
				filter : {
					showIcon : true
				},
			}, 
			{
				headerText : "코드",
				dataField : "job_cd",
				style : "aui-center",
				width : "50",
				minWidth : "50",
				editable : false,
				filter : {
					showIcon : true
				},
				visible : true
			}];

			auiGridJob = AUIGrid.create("#auiGridJob", columnLayout, gridPros);
			var originJobList = ${originJobList}
			AUIGrid.setGridData(auiGridJob, originJobList);
			AUIGrid.bind(auiGridJob, "cellClick", function(event) {
				/* var param = {
					"org_code" : event.item["org_code"]
				}; */
			});
			AUIGrid.resize(auiGridJob);
		}
		
		// 직책트리
		function createAUIGridGrade() {
			var gridPros = {
				rowIdField : "grade_cd",
				height : 483,
				displayTreeOpen : false,
				rowCheckDependingTree : true,
				showRowNumColumn : false,
				enableFilter : true,
				showRowCheckColumn: true,
				treeColumnIndex : 0,
			};
			var columnLayout = [ 
			{
				headerText : "직책",
				dataField : "grade_name",
				style : "aui-left",
				editable : false,
				width : "200",
				minWidth : "100",
				filter : {
					showIcon : true
				},
			}, 
			{
				headerText : "코드",
				dataField : "grade_cd",
				style : "aui-center",
				width : "50",
				minWidth : "50",
				editable : false,
				filter : {
					showIcon : true
				},
				visible : true
			}];

			auiGridGrade = AUIGrid.create("#auiGridGrade", columnLayout, gridPros);
			var originGradeList = ${originGradeList}
			AUIGrid.setGridData(auiGridGrade, originGradeList);
			AUIGrid.resize(auiGridGrade);
		}
		
		// 조직트리
		function createAUIGridOrg() {
			var gridPros = {
				rowIdField : "org_code",
				height : 483,
				displayTreeOpen : false,
				rowCheckDependingTree : true,
				showRowNumColumn : false,
				enableFilter : true,
				showRowCheckColumn: true,
				treeColumnIndex : 0,
			};
			var columnLayout = [ 
			{
				headerText : "조직",
				dataField : "org_name",
				style : "aui-left",
				editable : false,
				width : "190",
				minWidth : "100",
				filter : {
					showIcon : true
				},
			}, 
			{
				headerText : "코드",
				dataField : "org_code",
				style : "aui-center",
				width : "50",
				minWidth : "50",
				editable : false,
				filter : {
					showIcon : true
				},
				visible : true
			}, 
			{
				headerText : "구분",
				dataField : "org_gubun_name",
				style : "aui-center",
				editable : false,
				width : "50",
				minWidth : "50",
				filter : {
					showIcon : true
				}
			}
			];

			auiGridOrg = AUIGrid.create("#auiGridOrg", columnLayout, gridPros);
			
			var originOrgList = ${originOrgList}
			AUIGrid.setGridData(auiGridOrg, originOrgList);
			AUIGrid.bind(auiGridOrg, "cellClick", function(event) {

			});
			AUIGrid.resize(auiGridOrg);
			
			AUIGrid.expandAll(auiGridOrg);
		}
		
		
		// 카테고리 트리 그리드
		function createAUIGridCategory() {
			var gridPros = {
				height : "555",
				rowIdField : "menu_code",
				displayTreeOpen :true,
				rowCheckDependingTree : true,
				showRowNumColumn: false,
				enableFilter :true,
			};
			var columnLayout = [
				{ 
					headerText : "카테고리구분", 
					dataField : "menu_name", 
 					width : "240",  
 					minWidth : "240",
					style : "aui-left",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "코드",
					dataField : "menu_code", 
					width : "40",
					minWidth : "40",
					visible : true,
				},
				{
					headerText : "순서",
					dataField : "sort_no",
					width : "40",
					minWidth : "40",
					visible : true,
				}
			];
			
			auiGridCategory = AUIGrid.create("#auiGridCategory", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridCategory, []);
			$("#auiGridCategory").resize();
			AUIGrid.bind(auiGridCategory, "cellClick", function(event){
				var menuCode = event.item["menu_code"];
				goDetail(menuCode);      
			});
			AUIGrid.resize(auiGridCategory);
		};
		
		function goUpCategorySearch() {
			$M.goNextPageAjax(this_page + "/up", '' , { method : 'get'},
					function(result) {            
						if (result.success) {
							//페이지 정보 TABLE FORM의 상위메뉴select에 데이터 값 입력
							upMenuCodeDom.html("");
							var option1 = $("<option></option>");
							option1.val("");
							option1.text("- 선택 -");
							upMenuCodeDom.append(option1);
							var comboList = result.list;
							for(var i = 0 ; i < comboList.length ; i++) {
								var option = $("<option></option>");
								option.val(comboList[i].menu_code);
								option.text(comboList[i].path_menu_name);
								upMenuCodeDom.append(option);
								/* if (comboList[i].children) {
									var cList = comboList[i].children; 
									for (var j = 0; j < cList.length; ++j) {
										var option = $("<option></option>");
										option.val(cList[j].menu_code);
										option.text(cList[j].path_menu_name);
										upMenuCodeDom.append(option);
									}
								} */
							}
						};
					}
				)
		}
		
		// 조회
		   function goSearch() {
				var params = {
					"s_menu_name" : $M.getValue("s_menu_name")
				};
				$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), { method : 'get'},
					function(result) {
						if(result.success) {
							fnNew();
							AUIGrid.setGridData(auiGridCategory, result.list);
							$("#total_cnt").html(result.total_cnt);
						}
					}
				);
			}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="control" name="control" value="C">
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
					<!-- /검색영역 -->
					<div class="row">
						<div class="col-3">
					<!-- 카테고리 -->
							<div class="title-wrap mt10">
								<h4>카테고리</h4>
								<div class="btn-group">
									<div class="right">
										<button type="button" onclick=AUIGrid.expandAll(auiGridCategory); class="btn btn-default"><i class="material-iconsadd text-default"></i>펼침</button>
										<button type="button" onclick=AUIGrid.collapseAll(auiGridCategory); class="btn btn-default"><i class="material-iconsremove text-default"></i>접힘</button>
									</div>
								</div>
							</div>
							<div class="mt5" id="auiGridCategory"></div>
					<!-- /카테고리 -->
						</div>
						<div class="col-9">
					<!-- 조회결과 -->
							<div class="row">
								<!-- 카테고리정보 -->								
								<div class="col-12">
									<div class="title-wrap mt10">
										<h4>카테고리정보</h4>					
									</div>									
									<!-- 폼테이블 -->	
									<div>
										<table class="table-border mt5">
											<colgroup>
												<col width="85px"> <!-- 100에서 75로수정-->
												<col width="">
												<col width="85px">
												<col width="">
												<col width="75px"> <!-- 100에서 75로수정-->
												<col width="">
											</colgroup>
											<tbody>
												<tr>
													<th class="text-right essential-item">카테고리명</th>
													<td>
														<input type="text" class="form-control essential-bg width230px" id="menu_name" name="menu_name" alt="카테고리명" size="20" maxlength="50" required="required">
													</td>
													<th class="text-right essential-item">카테고리코드</th>
													<td>
														<input type="text" id="menu_code" name="menu_code" class="form-control essential-bg width230px" alt="카테고리코드" size="2" maxlength="2" format="num" required="required" placeholder="2자리 숫자, 중복되지않아야함">
													</td>
													<th class="text-right essential-item">사용여부</th>
													<td>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="Y" id="use_yn_y">
															<label class="form-check-label" for="use_yn_y">Y</label>
														</div>
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" name="use_yn" value="N" id="use_yn_n">
															<label class="form-check-label" for="use_yn_n">N (삭제)</label>
														</div>
													</td>
												</tr>
												<tr>
													<th class="text-right essential-item">순서</th>
													<td>
														<div class="form-row inline-pd">
															<div class="col-auto">
																<input type="text" class="form-control essential-bg width40px" id="sort_no" name="sort_no" format="num" alt="순서" style="padding : 5px;" min="1" datatype="int" required="required" size="20" maxlength="22">
															</div>
															<div class="col-auto">
																<div class="form-check form-check-inline" style="margin-right: 0; margin-left: 5px">
																	<input class="form-check-input" id="after_menu_push" name="after_menu_push" type="checkbox" style="margin-top: 6px; margin-right: 3px;" alt="" value="Y">
																	<label class="form-check-label" for="after_menu_push">후순위 메뉴밀기</label>
																</div>
															</div>
														</div>
													</td>
													<th class="text-right essential-item">상위카테고리</th>
													<td colspan="3">
														<div class="form-row inline-pd">
															<div class="col-auto">
																<select id="up_menu_code" name="up_menu_code" class="" style="height:24px; max-width: 280px;" alt="상위카테고리">
																	<option value="">- 선택 -</option>
																</select>
															</div>
															<div class="col-auto">
																<div class="form-check form-check-inline" style="margin-right: 0; margin-left: 5px" onclick="fnUpMenuAction();">
																	<input class="form-check-input" id="up_menu_chk" name="up_menu_chk" type="checkbox" style="margin-top: 6px; margin-right: 3px;" alt="" value="Y">
																	<label class="form-check-label" for="up_menu_chk">최상위 카테고리</label>
																</div>
															</div>
														</div>
													</td>
												</tr>
											</tbody>
										</table>
									</div>
<!-- /폼테이블 -->
									<!-- 폼테이블 -->	
									<div class="row">
										<div class="col-4">
											<div class="title-wrap mt10">
												<h4>접근관리</h4>
												<div class="btn-group">
													<div class="right">
														<button type="button" onclick=AUIGrid.expandAll(auiGridOrg); class="btn btn-default"><i class="material-iconsadd text-default"></i>펼침</button>
														<button type="button" onclick=AUIGrid.collapseAll(auiGridOrg); class="btn btn-default"><i class="material-iconsremove text-default"></i>접힘</button>
													</div>
												</div>
											</div>
											<div class="mt5" id="auiGridOrg"></div>
										</div>
										<div class="col-4">
											<div class="title-wrap mt10">
												<div class="btn-group">
													<div class="right">
													</div>
												</div>
											</div>
											<div class="mt5" id="auiGridGrade"></div>
										</div>
										<div class="col-4">
											<div class="title-wrap mt10">
												<div class="btn-group">
													<div class="right">
													</div>
												</div>
											</div>
											<div class="mt5" id="auiGridJob"></div>
										</div>
									</div>

<!-- 그리드 서머리, 컨트롤 영역 -->
									<div class="btn-group mt5">					
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
										</div>
									</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
								</div>
<!-- /메뉴정보 -->									
							</div>	
					<!-- /조회결과 -->		
						</div>
					</div>
				</div>
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>
